//
//  AGAcummulatorConverter.swift
//  
//
//  Created by Antony Gardiner on 31/05/23.
//

import Foundation
import AGCore
import FitDataProtocol
import AntMessageProtocol

public enum AGConverterError: Error {
	case failedToSaveFit
}

public struct AGDeveloperDataField {
	var name: String
	var fieldDefinitionNumber: UInt8
	var baseUnit: BaseType
	
	/// Optional native message num that this field is attached to
	var nativeMessageNum: UInt16?
}

public struct AGDeveloperData {
	var developerDataIndex: UInt8 = 0 // a sensible default
	var fields: [AGDeveloperDataField] = []
}

public struct AGConverterConfig {
	public var name: String?
	public var sport: Sport
	public var subSport: SubSport
	public var developerData: AGDeveloperData?
}

/// Converts raw data into fit messages.

public class AGAcummulatorConverter {

	private let acummulator: AGAccumulator
	private let fitWriter: AGFitWriter
	private let config: AGConverterConfig
	
	init(config: AGConverterConfig, acummulator: AGAccumulator, fitWriter: AGFitWriter) {
		self.acummulator = acummulator
		self.fitWriter = fitWriter
		self.config = config
	}
	
	// MARK: - convert raw messages into fit messages.
		
	/// Processes all accumulated and raw data and generates fit messages into the the fit write ready for saving to fit file.
	/// - Returns: Nil or an error
	public func convert() async -> AGConverterError? {
	
		let startDate = acummulator.startDate ?? Date()
		
		// Add a file Id message.
		fitWriter.appendMessage(message: createFileIdMessage(name: config.name, date: startDate))
		
		// Add developer fields if they exist.
		if let devData = config.developerData {
			
			// Add developer data id messages
			fitWriter.appendMessage(message: createDeveloperDataIdMessage())
			
			// Add Field description messages
			for devField in devData.fields {
				let fieldDescMessage = createFieldDescriptionMessage(
					name: devField.name,
					developerDataIndex: devData.developerDataIndex,
					fieldDefinitionNumber: devField.fieldDefinitionNumber,
					messageNumber: devField.nativeMessageNum,
					baseUnit: devField.baseUnit)
				fitWriter.appendMessage(message: fieldDescMessage)
			}
		}

		// Add sport messsage
		fitWriter.appendMessage(message: createSportMessage(name: config.name,
															sport: config.sport,
															subSport: config.subSport))

		// If we have sensor data we could also add device info messages.
		
		// Add a Start Event.
		fitWriter.appendMessage(message: createEventMessage(date: startDate, eventType: .start))
		
		// Loop through all instand data and create record messages
		let lastRecordDate = createRecordMessages(startDate: startDate)
		
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
		fitWriter.appendMessage(message: createActivityMessage(startTime: startDate,
															   date: lastRecordDate, allSessions:
																acummulator.sessionData))
		
		return nil
	}
	
	internal func createRecordMessages(startDate: Date) -> Date {
	
		var paused = false
		
		var lastRecordDate = startDate
		
		for second in acummulator.rawData.data.keys.sorted() {
			
			let recordDate = startDate.addingTimeInterval(TimeInterval(second))
			
			guard let instantData: AGAccumulatorRawInstantData = acummulator.rawData.data[second] else {
				continue
			}
			
			// if not paused and now paused then
			if !paused && instantData.paused {
				// add a pause event
				fitWriter.appendMessage(message: createEventMessage(date: recordDate, eventType: .stop))
			}
			// if paused and now not paused, then
			else if paused && !instantData.paused {
				// add a resume event
				fitWriter.appendMessage(message: createEventMessage(date: recordDate, eventType: .start))
			}
			
			paused = instantData.paused
			
			if !paused {
				// Add record messages
				fitWriter.appendMessage(message: createRecordMessage(date: recordDate, rawData: instantData))
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
	
	internal func createRecordMessage(date: Date, rawData: AGAccumulatorRawInstantData) -> RecordMessage {
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
				
		return RecordMessage(timeStamp: fitTime,
							 position: position,
							 distance: distanceMeasurement,
							 altitude: altitudeMeasurement,
							 speed: speedMeasurement,
							 gpsAccuracy: gpsAccuracyMeasurement)
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
		
		// total lap time (paused + elapsed)
		let totalTimeS = lapData.totalTimeS
		let totalTimerTime: Measurement<UnitDuration> = Measurement(value: totalTimeS, unit: .seconds)
		
		// total elaspsed time
		let totalElapsedTime: Measurement<UnitDuration> = Measurement(value: lapData.durationS, unit: .seconds)
		
		// total distance
		var totalDistanceMeasurement: Measurement<UnitLength>? = nil
		if let totalDistance = lapData.value(for: .distance, avgType: .last) {
			totalDistanceMeasurement = Measurement(value: totalDistance, unit: .meters)
		}

		// avg speed
		var averageSpeedMeasurement: Measurement<UnitSpeed>? = nil
		if let avgSpeed = lapData.value(for: .speed, avgType: .average) {
			averageSpeedMeasurement = Measurement(value: avgSpeed, unit: .metersPerSecond)
		}
		
		return LapMessage(timeStamp: fitTime,
						  event: event,
						  eventType: eventType,
						  startTime: startTime,
						  totalElapsedTime: totalElapsedTime,
						  totalTimerTime: totalTimerTime,
						  totalDistance: totalDistanceMeasurement,
						  averageSpeed: averageSpeedMeasurement)
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

		// total session time (paused + elapsed)
		let totalTimeS = sessionData.totalTimeS
		let totalSessionTime: Measurement<UnitDuration> = Measurement(value: totalTimeS, unit: .seconds)
		
		// total elaspsed time
		let totalElapsedTime: Measurement<UnitDuration> = Measurement(value: sessionData.durationS, unit: .seconds)
		
		// avg speed
		var averageSpeedMeasurement: Measurement<UnitSpeed>? = nil
		if let avgSpeed = sessionData.value(for: .speed, avgType: .average) {
			averageSpeedMeasurement = Measurement(value: avgSpeed, unit: .metersPerSecond)
		}
		
		// total distance
		var totalDistanceMeasurement: Measurement<UnitLength>? = nil
		if let totalDistance = sessionData.value(for: .distance, avgType: .last) {
			totalDistanceMeasurement = Measurement(value: totalDistance, unit: .meters)
		}
		
		// num laps
		let numLaps: UInt16 = 1
		
		return SessionMessage(timeStamp: fitTime,
							  event: event,
							  eventType: eventType,
							  startTime: startTime,
							  sport: sport,
							  subSport: subSport,
							  totalElapsedTime: totalElapsedTime,
							  totalTimerTime: totalSessionTime,
							  totalDistance: totalDistanceMeasurement,
							  averageSpeed: averageSpeedMeasurement,
							  numberOfLaps: numLaps)
	}
	
	internal func createActivityMessage(startTime: Date, date: Date, allSessions: AGAccumulatorMultiData) -> ActivityMessage {
		let fitTime = FitTime(date: date)
		
		// local time stamp
		let fitLocalTime = FitTime(date: startTime, isLocal: true)
		
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
	public func write() async -> AGConverterError? {
		
		let result = fitWriter.write()
		if result != nil {
			return AGConverterError.failedToSaveFit
		}
		
		return nil
	}
	
}
