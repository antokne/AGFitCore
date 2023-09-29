//
//  AGAcummulatorConverter.swift
//  
//
//  Created by Antony Gardiner on 31/05/23.
//

import Foundation
import os
import AGCore
import FitDataProtocol
import AntMessageProtocol

public enum AGFitConverterError: Error {
	case failedToSaveFit
	case invalidStartDate
}

/// Converts raw data into fit messages.
/// Note that this converts accumulated data into a fit file
public class AGFitAcummulatorConverter {

	private let acummulator: AGAccumulator
	private let fitWriter: AGFitWriter
	private let config: AGFitConverterConfig
	
	private var logger = Logger(subsystem: "com.antokne.fitcore", category: "AGFitAcummulatorConverter")

	private var fieldDescriptionMessages: [FieldDescriptionMessage] = []
    
    /// Converts accumulated data into fit messages
    /// - Parameters:
    ///   - config: config to use during the process
    ///   - acummulator: the accumulated data to convert
    ///   - fitWriter: the fit write to use to write to a file.
	public init(config: AGFitConverterConfig, acummulator: AGAccumulator, fitWriter: AGFitWriter) {
		self.acummulator = acummulator
		self.fitWriter = fitWriter
		self.config = config
	}
	
	// MARK: - convert raw messages into fit messages.
		
	/// Processes all accumulated and raw data and generates fit messages into the the fit writer ready for saving to fit file.
	/// - Returns: Nil or an error
	public func convertToFitMessages() async -> AGFitConverterError? {
			
		let startDateGMT = acummulator.startDate ?? Date()

		logger.info("Started convert to Fit startDateGMT    = \(startDateGMT, privacy: .public)")

		// GMT Based start date.
		guard let startDateLocal = Calendar.gmt.dateBySettingTimeFrom(timeZone: TimeZone.current, of: startDateGMT) else {
			logger.error("Failed to generate fit for startDateLocal = \(startDateGMT, privacy: .public)")
			return AGFitConverterError.invalidStartDate
		}
		
		logger.info("Started convert to Fit local startDate = \(startDateLocal, privacy: .public)")

		// Add a file Id message.
		fitWriter.appendMessage(message: createFileIdMessage(name: config.name, date: startDateGMT))
		
		// Add developer fields if they exist.
		if let devData = config.developerData {
			
			// Add developer data id messages
			fitWriter.appendDeveloperDataId(developerDataID: createDeveloperDataIdMessage(devDataIndex: devData.developerDataIndex))
			
			logger.info("Adding \(devData.fields.count, privacy: .public) dev data fields.")

			// Add Field description messages
			for devField in devData.fields {
				let fieldDescMessage = createFieldDescriptionMessage(
					name: devField.name,
					developerDataIndex: devData.developerDataIndex,
					fieldDefinitionNumber: devField.fieldDefinitionNumber,
					messageNumber: devField.nativeMessageNum,
					baseUnit: devField.baseUnit)
				fitWriter.appendFieldDescription(fieldDescription: fieldDescMessage)
				fieldDescriptionMessages.append(fieldDescMessage)
			}
		}

		// Add sport messsage
		fitWriter.appendMessage(message: createSportMessage(sport: config.sport,
															subSport: config.subSport))

		// If we have sensor data we could also add device info messages.
		
		// Add a Start Event.
		fitWriter.appendMessage(message: createEventMessage(date: startDateGMT, eventType: .start))
		
		// Loop through all instand data and create record messages
		let lastRecordDate = createRecordMessages(startDate: startDateGMT)
		
		// Add a Stop all Event.
		fitWriter.appendMessage(message: createEventMessage(date: lastRecordDate,
															eventType: .stopAll))
		
		// Add lap message at the end
		fitWriter.appendMessage(message: createLapMessage(date: lastRecordDate,
														  lapData: acummulator.lapData.currentData))

		// Add session message at the end
		fitWriter.appendMessage(message: createSessionMessage(date: lastRecordDate,
															  sessionData: acummulator.sessionData.currentData))

		// activity message at the very end
		fitWriter.appendMessage(message: createActivityMessage(date: lastRecordDate,
															   allSessions: acummulator.sessionData))
		
		logger.info("Completed convert to Fit.")
		return nil
	}
	
	/// Interates over all accumulated raw data and creates a record message at 1Hz.
	/// - Parameter startDate: the activity start date.
	/// - Returns: Last record date.
	internal func createRecordMessages(startDate: Date) -> Date {
	
		var paused = false
		
		var lastRecordDate = startDate
		
		logger.info("Generating \(self.acummulator.rawData.data.keys.count, privacy: .public) messages.")
		
		for second in acummulator.rawData.data.keys.sorted() {
			
			let recordDate = startDate.addingTimeInterval(TimeInterval(second))
			
			/// The data for this timestamp or second in the recorded activity
			guard let secondData: AGAccumulatorRawInstantData = acummulator.rawData.data[second] else {
				continue
			}
			
			let arrayData = acummulator.rawData.arrayData[second]
			
			// if not paused and now paused then
			if !paused && secondData.paused {
				// add a pause event
				fitWriter.appendMessage(message: createEventMessage(date: recordDate, eventType: .stop))
			}
			// if paused and now not paused, then
			else if paused && !secondData.paused {
				// add a resume event
				fitWriter.appendMessage(message: createEventMessage(date: recordDate, eventType: .start))
			}
			
			paused = secondData.paused
			
			if !paused {
				// Add record messages
				fitWriter.appendMessage(message: createRecordMessage(date: recordDate,
																	 rawData: secondData,
																	 arrayData: arrayData))
			}
				
			lastRecordDate = recordDate
		}
		return lastRecordDate
	}
	
	// MARK: - Create messages

	internal func createFileIdMessage(name: String? = nil,
									  date: Date = Date(),
									  manufacturerId: Int = 0,
									  fileType: FileType = .activity) -> FileIdMessage {
		
		// time created -> Now
		// Type 		-> Activity
		// manufacturer -> Default to unknown.
		
		let fitTime = FitTime(date: date)
		let manufacturer = Manufacturer.supportedManufacturers.first(where: { $0.manufacturerID == manufacturerId }) ?? Manufacturer.unknown
		return FileIdMessage(fileCreationDate: fitTime,
							 manufacturer: manufacturer,
							 fileType: fileType,
							 productName: name)
	}
	
	internal func createFieldDescriptionMessage(name: String,
												developerDataIndex: UInt8,
												fieldDefinitionNumber: UInt8,
												messageNumber: UInt16? = nil,
												units: String? = nil,
												baseUnit: BaseType) -> FieldDescriptionMessage {
		
		let baseType = BaseTypeData(type: baseUnit)
		return FieldDescriptionMessage(dataIndex: developerDataIndex,
									   definitionNumber: fieldDefinitionNumber,
									   fieldName: name,
									   baseInfo: baseType,
									   units: units,
									   baseUnits: nil,
									   messageNumber: messageNumber,
									   fieldNumber: nil) // do not use.
	}

	internal func createDeveloperDataIdMessage(devDataIndex: UInt8 = 0) -> DeveloperDataIdMessage {
		return DeveloperDataIdMessage(dataIndex: devDataIndex)
	}

	internal func createSportMessage(name: String? = nil,
									 sport: Sport,
									 subSport: SubSport) -> SportMessage {
		return SportMessage(name: name, sport: sport, subSport: subSport)
	}
	
	internal func createRecordMessage(date: Date,
									  rawData: AGAccumulatorRawInstantData,
									  arrayData: AGAccumulatorRawArrayInstantData?) -> RecordMessage {
		let fitTime = FitTime(date: date)
		
		// Position lat/lng
		var position: Position? = nil
		if let lat = rawData.value(for: .latitude),
		   let lng = rawData.value(for: .longitude) {
			let latMeasurement = Measurement(value: lat, unit: UnitAngle.degrees)
			let lngMeasurement = Measurement(value: lng, unit: UnitAngle.degrees)
			position = Position(latitude: latMeasurement, longitude: lngMeasurement)
		}
		
		// Speed
		var speedMeasurement: Measurement<UnitSpeed>? = nil
		if let speed = rawData.value(for: .speed) {
			speedMeasurement = Measurement(value: speed, unit: .metersPerSecond)
		}
		
		// distance accum
		var distanceMeasurement: Measurement<UnitLength>? = nil
		if let distance = rawData.value(for: .distance) {
			distanceMeasurement = Measurement(value: distance, unit: .meters)
		}
		
		// altitude
		var altitudeMeasurement: Measurement<UnitLength>? = nil
		if let altitude = rawData.value(for: .altitude) {
			altitudeMeasurement = Measurement(value: altitude, unit: .meters)
		}
		
		// gps accuracy
		var gpsAccuracyMeasurement: Measurement<UnitLength>? = nil
		if let gpsVertAccuracy = rawData.value(for: .verticalAccuracy) {
			gpsAccuracyMeasurement = Measurement(value: gpsVertAccuracy, unit: .meters)
		}
		
		let recordMessage = RecordMessage(timeStamp: fitTime,
										  position: position,
										  distance: distanceMeasurement,
										  altitude: altitudeMeasurement,
										  speed: speedMeasurement,
										  gpsAccuracy: gpsAccuracyMeasurement)

		recordMessage.encodeDevDataFields(fieldDescriptionMessages: fieldDescriptionMessages,
										  rawData: rawData,
										  arrayData: arrayData)
		
		return recordMessage
	}

	internal func createEventMessage(date: Date,
									 event: Event = .timer,
									 eventType: EventType) -> EventMessage {
		let fitTime = FitTime(date: date)
		return EventMessage(timeStamp: fitTime, event: event, eventType: eventType)
	}
	
	internal func createLapMessage(date: Date, lapData: AGAccumulatorData) -> LapMessage {
		let fitTime = FitTime(date: date)
		
		// start time. of lap
		let startTime = FitTime(date: lapData.startDate)
		
		// event type = stop
		let eventType = EventType.stop
		
		// event = lap
		let event = Event.lap
		
		// total lap time
		let totalTimerTime: Measurement<UnitDuration> = Measurement(value: lapData.durationS, unit: .seconds)
		
		// total elaspsed time (paused + elapsed)
		let totalElapsedTime: Measurement<UnitDuration> = Measurement(value: lapData.totalTimeS, unit: .seconds)
		
		// total distance
		var totalDistanceMeasurement: Measurement<UnitLength>? = nil
		if let totalDistance = lapData.value(for: .distance, avgType: .last) {
			totalDistanceMeasurement = Measurement(value: totalDistance, unit: .meters)
		}

		// avg speed
		var averageSpeedMeasurement: Measurement<UnitSpeed>? = nil
		if let avgSpeed = lapData.value(for: .distance, avgType: .accumulationOverTime) {
			averageSpeedMeasurement = Measurement(value: avgSpeed, unit: .metersPerSecond)
		}
		
		// max speed
		var maxSpeedMeasurement: Measurement<UnitSpeed>? = nil
		if let maxSpeed = lapData.value(for: .speed, avgType: .max) {
			maxSpeedMeasurement = Measurement(value: maxSpeed, unit: .metersPerSecond)
		}
		
		let lapMessage = LapMessage(timeStamp: fitTime,
									event: event,
									eventType: eventType,
									startTime: startTime,
									totalElapsedTime: totalElapsedTime,
									totalTimerTime: totalTimerTime,
									totalDistance: totalDistanceMeasurement,
									averageSpeed: averageSpeedMeasurement,
									maximumSpeed: maxSpeedMeasurement)

		let fields = fieldDescriptionMessages.fields(for: LapMessage.globalMessageNumber())
		for field in fields {
			
			var value: Any? = nil
			
			switch field.definitionNumber {
			case AGFitDeveloperData.RadarCountLapFieldId:
				if let doubleValue = lapData.value(for: .radarTargetTotalCount, avgType: .last) {
					value = UInt16(doubleValue)
				}
				
			default:
				break
			}
			
			if let value {
				lapMessage.addDeveloperData(value: value, fieldDescription: field)
			}
		}
		
		return lapMessage
	}

	internal func createSessionMessage(date: Date, sessionData: AGAccumulatorData) -> SessionMessage {
		let fitTime = FitTime(date: date)
		
		// start time
		let startTime = FitTime(date: sessionData.startDate)
		
		//event type = stop
		let eventType = EventType.stop

		// sport
		let sport = config.sport
		
		// subsport
		let subSport = config.subSport
		
		// event = session
		let event = Event.session

		// total session time
		let totalSessionTime: Measurement<UnitDuration> = Measurement(value: sessionData.durationS, unit: .seconds)
		
		// total elaspsed time (paused + elapsed)
		let totalElapsedTime: Measurement<UnitDuration> = Measurement(value: sessionData.totalTimeS, unit: .seconds)
		
		// avg speed
		var averageSpeedMeasurement: Measurement<UnitSpeed>? = nil
		if let avgSpeed = sessionData.value(for: .distance, avgType: .accumulationOverTime) {
			averageSpeedMeasurement = Measurement(value: avgSpeed, unit: .metersPerSecond)
		}
		
		// max speed
		var maximumSpeedMeasurement: Measurement<UnitSpeed>? = nil
		if let maxSpeed = sessionData.value(for: .speed, avgType: .max) {
			maximumSpeedMeasurement = Measurement(value: maxSpeed, unit: .metersPerSecond)
		}
		
		// total distance
		var totalDistanceMeasurement: Measurement<UnitLength>? = nil
		if let totalDistance = sessionData.value(for: .distance, avgType: .last) {
			totalDistanceMeasurement = Measurement(value: totalDistance, unit: .meters)
		}
		
		// num laps
		let numLaps: UInt16 = 1
		
		let sessionMessage = SessionMessage(timeStamp: fitTime,
											event: event,
											eventType: eventType,
											startTime: startTime,
											sport: sport,
											subSport: subSport,
											totalElapsedTime: totalElapsedTime,
											totalTimerTime: totalSessionTime,
											totalDistance: totalDistanceMeasurement,
											averageSpeed: averageSpeedMeasurement,
											maximumSpeed: maximumSpeedMeasurement,
											numberOfLaps: numLaps)
		
		let fields = fieldDescriptionMessages.fields(for: SessionMessage.globalMessageNumber())
		for field in fields {
			
			var value: Any? = nil
			
			switch field.definitionNumber {
			case AGFitDeveloperData.RadarCountSessionFieldId:
				if let doubleValue = sessionData.value(for: .radarTargetTotalCount, avgType: .last) {
					value = UInt16(doubleValue)
				}
			default:
				break
			}
			
			if let value {
				sessionMessage.addDeveloperData(value: value, fieldDescription: field)
			}
		}
		
		return sessionMessage
	}
	
	internal func createActivityMessage(date: Date, allSessions: AGAccumulatorMultiData) -> ActivityMessage {
		let fitTime = FitTime(date: date)
		
		let startDateLocal = Calendar.gmt.dateBySettingTimeFrom(timeZone: TimeZone.current, of: date) ?? date
		
		// local time stamp
		let fitLocalTime = FitTime(date: startDateLocal, isLocal: false)
		
		// event type = stop
		let eventType = EventType.stop
		
		// activity type = manual
		let activity = Activity.manual
		
		// event = activity
		let event = Event.activity
		
		// total timer time (all sessions)
		// num sessions
		let numOfSessions: UInt16 = 1
		
		// this should be accumlative of all sessions.
		let totalTimeS = allSessions.activityTotalTime
		let totalSessionTime: Measurement<UnitDuration> = Measurement(value: totalTimeS, unit: .seconds)
		
		return ActivityMessage(timeStamp: fitTime,
							   totalTimerTime: totalSessionTime,
							   localTimeStamp: fitLocalTime,
							   numberOfSessions: numOfSessions,
							   activity: activity,
							   event: event,
							   eventType: eventType)
	}
	
	/// Writres all the fit messages to a fit file
	/// - Returns: nil or an error.
	public func write() async -> AGFitConverterError? {
		
		let result = fitWriter.write()
		if result != nil {
			return AGFitConverterError.failedToSaveFit
		}
		
		return nil
	}
	
}

extension Array where Element == FieldDescriptionMessage {
	
	func fields(for messageNum: UInt16) -> [FieldDescriptionMessage] {
		self.filter { ($0.messageNumber ?? 0) == messageNum }
	}
}
