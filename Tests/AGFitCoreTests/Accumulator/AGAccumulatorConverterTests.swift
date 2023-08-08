//
//  AGAccumulatorConverterTests.swift
//  
//
//  Created by Antony Gardiner on 1/06/23.
//

import XCTest
@testable import AGFitCore
import AGCore
import FitDataProtocol
import AntMessageProtocol

final class AGAccumulatorConverterTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testFieldDescriptionMessages() throws {
		
		let url = try XCTUnwrap(URL.tempFitFile())
		let fitWriter = MockAGFitWriter(fileURL: url)
		
		let config = AGFitConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road, metric: true)
		let accumulator = AGAccumulator()
		
		var fieldDescriptionMessages: [FieldDescriptionMessage] = []
		let converter = AGFitAcummulatorConverter(config: config,
											   acummulator: accumulator,
											   fitWriter: fitWriter)

		var fields = fieldDescriptionMessages.fields(for: 10)
		XCTAssertEqual(fields.count, 0)
		
		let fieldDescMessage = converter.createFieldDescriptionMessage(
			name: "bon",
			developerDataIndex: 0,
			fieldDefinitionNumber: 1,
			messageNumber: 20,
			baseUnit: BaseType.sint8)
		fieldDescriptionMessages.append(fieldDescMessage)
		
		fields = fieldDescriptionMessages.fields(for: 10)
		XCTAssertEqual(fields.count, 0)
	
		fields = fieldDescriptionMessages.fields(for: 20)
		XCTAssertEqual(fields.count, 1)
	
	}
	
	
	func testFitMessageGenerationNoData() async throws {
		
		let url = try XCTUnwrap(URL.tempFitFile())
		let fitWriter = MockAGFitWriter(fileURL: url)
		
		let config = AGFitConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road, metric: true)
		let accumulator = AGAccumulator()
		
		let date = Date()
		accumulator.event(event: .start, at: date)
		accumulator.event(event: .stop, at: date)
		
		let converter = AGFitAcummulatorConverter(config: config,
											   acummulator: accumulator,
											   fitWriter: fitWriter)
		
	
		let result = await converter.convertToFitMessages()
		XCTAssertNil(result)
		
		XCTAssertEqual(fitWriter.messages.count, 7)
		
		// File Id message
		let fileIdMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? FileIdMessage) != nil }) as? FileIdMessage)
		var timeInterval = try XCTUnwrap(fileIdMessage.fileCreationDate?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		
		XCTAssertEqual("Road Cycling", fileIdMessage.productName)
		XCTAssertEqual(FileType.activity, fileIdMessage.fileType)
		XCTAssertEqual(Manufacturer.unknown, fileIdMessage.manufacturer)

		// Sport Message
		let sportMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? SportMessage) != nil }) as? SportMessage)
		XCTAssertEqual(sportMessage.sport, Sport.cycling)
		XCTAssertEqual(sportMessage.subSport, SubSport.road)

		// Event messages
		let eventMessages = try XCTUnwrap(fitWriter.messages.filter { ($0 as? EventMessage) != nil } as? [EventMessage])
		XCTAssertEqual(eventMessages.count, 2)

		// Event Message start
		var eventMessage = try XCTUnwrap(eventMessages.first)
		timeInterval = try XCTUnwrap(eventMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(eventMessage.eventType, EventType.start)

		// Event Message stopall
		eventMessage = try XCTUnwrap(eventMessages.last)
		timeInterval = try XCTUnwrap(eventMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(eventMessage.eventType, EventType.stopAll)
		
		// Lap message
		let lapMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? LapMessage) != nil }) as? LapMessage)
		timeInterval = try XCTUnwrap(lapMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(lapMessage.totalTimerTime?.value, 0)
		XCTAssertEqual(lapMessage.totalElapsedTime?.value, 0)
		XCTAssertEqual(lapMessage.eventType, EventType.stop)
		

		// session message
		let sessionMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? SessionMessage) != nil }) as? SessionMessage)
		timeInterval = try XCTUnwrap(sessionMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(sessionMessage.totalTimerTime?.value, 0)
		XCTAssertEqual(sessionMessage.totalElapsedTime?.value, 0)
		XCTAssertEqual(sessionMessage.sport, Sport.cycling)
		XCTAssertEqual(sessionMessage.subSport, SubSport.road)
		XCTAssertEqual(sessionMessage.eventType, EventType.stop)

		// activity message
		let activityMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? ActivityMessage) != nil }) as? ActivityMessage)
		timeInterval = try XCTUnwrap(activityMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(activityMessage.event, Event.activity)
		XCTAssertEqual(activityMessage.numberOfSessions, 1)
		XCTAssertEqual(activityMessage.activity, Activity.manual)
		XCTAssertEqual(activityMessage.eventType, EventType.stop)
	}
	
	func testFitMessageGenerationSomeData() async throws {
		
		let url = try XCTUnwrap(URL.tempFitFile())
		let fitWriter = MockAGFitWriter(fileURL: url)
		
		let config = AGFitConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road, metric: true)
		let accumulator = AGAccumulator()
		
		let date = Date()
		accumulator.event(event: .start, at: date)
		
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(3), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(4), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(5), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .distance)
		try accumulator.accumulate(date: date.plus(2), value: 2, type: .distance)
		try accumulator.accumulate(date: date.plus(3), value: 3, type: .distance)
		try accumulator.accumulate(date: date.plus(4), value: 4, type: .distance)
		try accumulator.accumulate(date: date.plus(5), value: 5, type: .distance)

		accumulator.event(event: .pause, at: date.plus(5))
		
		try accumulator.accumulate(date: date.plus(6), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(7), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(8), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(9), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(10), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(6), value: 5, type: .distance)
		try accumulator.accumulate(date: date.plus(7), value: 5, type: .distance)
		try accumulator.accumulate(date: date.plus(8), value: 5, type: .distance)
		try accumulator.accumulate(date: date.plus(9), value: 5, type: .distance)
		try accumulator.accumulate(date: date.plus(10), value: 5, type: .distance)
		accumulator.event(event: .resume, at: date.plus(10))

		try accumulator.accumulate(date: date.plus(11), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(12), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(13), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(14), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(15), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(11), value: 6, type: .distance)
		try accumulator.accumulate(date: date.plus(12), value: 7, type: .distance)
		try accumulator.accumulate(date: date.plus(13), value: 8, type: .distance)
		try accumulator.accumulate(date: date.plus(14), value: 9, type: .distance)
		try accumulator.accumulate(date: date.plus(15), value: 10, type: .distance)
		
		accumulator.event(event: .stop, at: date)
		
		let converter = AGFitAcummulatorConverter(config: config,
											   acummulator: accumulator,
											   fitWriter: fitWriter)
		
		
		let result = await converter.convertToFitMessages()
		XCTAssertNil(result)
		
		XCTAssertEqual(fitWriter.messages.count, 19)
		
		// File Id message
		let fileIdMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? FileIdMessage) != nil }) as? FileIdMessage)
		var timeInterval = try XCTUnwrap(fileIdMessage.fileCreationDate?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		
		XCTAssertEqual("Road Cycling", fileIdMessage.productName)
		XCTAssertEqual(FileType.activity, fileIdMessage.fileType)
		XCTAssertEqual(Manufacturer.unknown, fileIdMessage.manufacturer)
		
		// Sport Message
		let sportMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? SportMessage) != nil }) as? SportMessage)
		XCTAssertEqual(sportMessage.sport, Sport.cycling)
		XCTAssertEqual(sportMessage.subSport, SubSport.road)
		
		// Event messages
		let eventMessages = try XCTUnwrap(fitWriter.messages.filter { ($0 as? EventMessage) != nil } as? [EventMessage])
		XCTAssertEqual(eventMessages.count, 4)
		
		// Event Message start
		var eventMessage = try XCTUnwrap(eventMessages.first)
		timeInterval = try XCTUnwrap(eventMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(date.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(eventMessage.eventType, EventType.start)
		
		// record messages
		let recordMessages = try XCTUnwrap(fitWriter.messages.filter { ($0 as? RecordMessage) != nil } as? [RecordMessage])
		XCTAssertEqual(recordMessages.count, 10)
		
		let lastRecordMessage = try XCTUnwrap(recordMessages.last)
		
		let lastRecordMessageDate = try XCTUnwrap(lastRecordMessage.timeStamp?.recordDate)

		// Event Message stopall
		eventMessage = try XCTUnwrap(eventMessages.last)
		timeInterval = try XCTUnwrap(eventMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(lastRecordMessageDate.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(eventMessage.eventType, EventType.stopAll)
		
		// Lap message
		let lapMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? LapMessage) != nil }) as? LapMessage)
		timeInterval = try XCTUnwrap(lapMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(lastRecordMessageDate.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(lapMessage.totalTimerTime?.value, 10)
		XCTAssertEqual(lapMessage.totalElapsedTime?.value, 15)
		XCTAssertEqual(lapMessage.totalDistance?.value, 10)
		XCTAssertEqual(lapMessage.eventType, EventType.stop)
		XCTAssertEqual(lapMessage.averageSpeed?.value, 1)
		XCTAssertEqual(lapMessage.maximumSpeed?.value, 1)

		
		// session message
		let sessionMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? SessionMessage) != nil }) as? SessionMessage)
		timeInterval = try XCTUnwrap(sessionMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(lastRecordMessageDate.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(sessionMessage.totalTimerTime?.value, 10)
		XCTAssertEqual(sessionMessage.totalElapsedTime?.value, 15)
		XCTAssertEqual(sessionMessage.totalDistance?.value, 10)
		XCTAssertEqual(sessionMessage.sport, Sport.cycling)
		XCTAssertEqual(sessionMessage.subSport, SubSport.road)
		XCTAssertEqual(sessionMessage.eventType, EventType.stop)
		XCTAssertEqual(sessionMessage.averageSpeed?.value, 1)
		XCTAssertEqual(sessionMessage.maximumSpeed?.value, 1)
		
		// activity message
		let activityMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? ActivityMessage) != nil }) as? ActivityMessage)
		timeInterval = try XCTUnwrap(activityMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(lastRecordMessageDate.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(activityMessage.event, Event.activity)
		XCTAssertEqual(activityMessage.numberOfSessions, 1)
		XCTAssertEqual(activityMessage.activity, Activity.manual)
		XCTAssertEqual(activityMessage.eventType, EventType.stop)
		XCTAssertEqual(activityMessage.totalTimerTime?.value, 10)
	}
	
	func testFitMessageGenerationRadarData() async throws {
		
		let url = try XCTUnwrap(URL.tempFitFile())
		let fitWriter = MockAGFitWriter(fileURL: url)
		
		var config = AGFitConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road, metric: true)
		let accumulator = AGAccumulator()
		
		let date = Date()
		accumulator.event(event: .start, at: date)
		
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(3), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(4), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(5), value: 1, type: .speed)
		
		let radarRanges = AGDataTypeArrayValue(type: .radarRanges, values: [1,2,3,4,5,6,7,8])
		try accumulator.accumulate(date: date.plus(1), arrayValue: radarRanges)
		try accumulator.accumulate(date: date.plus(2), arrayValue: radarRanges)
		try accumulator.accumulate(date: date.plus(3), arrayValue: radarRanges)
		try accumulator.accumulate(date: date.plus(4), arrayValue: radarRanges)
		try accumulator.accumulate(date: date.plus(5), arrayValue: radarRanges)
		
		let radarSpeeds = AGDataTypeArrayValue(type: .radarSpeeds, values: [5,5,5,5,5,5,5,5])
		try accumulator.accumulate(date: date.plus(1), arrayValue: radarSpeeds)
		try accumulator.accumulate(date: date.plus(2), arrayValue: radarSpeeds)
		try accumulator.accumulate(date: date.plus(3), arrayValue: radarSpeeds)
		try accumulator.accumulate(date: date.plus(4), arrayValue: radarSpeeds)
		try accumulator.accumulate(date: date.plus(5), arrayValue: radarSpeeds)
		
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .radarPassingSpeed)
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .radarPassingSpeed)
		try accumulator.accumulate(date: date.plus(3), value: 1, type: .radarPassingSpeed)
		try accumulator.accumulate(date: date.plus(4), value: 1, type: .radarPassingSpeed)
		try accumulator.accumulate(date: date.plus(5), value: 1, type: .radarPassingSpeed)
		
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .radarPassingSpeedAbs)
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .radarPassingSpeedAbs)
		try accumulator.accumulate(date: date.plus(3), value: 1, type: .radarPassingSpeedAbs)
		try accumulator.accumulate(date: date.plus(4), value: 1, type: .radarPassingSpeedAbs)
		try accumulator.accumulate(date: date.plus(5), value: 1, type: .radarPassingSpeedAbs)
		
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .radarTargetTotalCount)
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .radarTargetTotalCount)
		try accumulator.accumulate(date: date.plus(3), value: 1, type: .radarTargetTotalCount)
		try accumulator.accumulate(date: date.plus(4), value: 1, type: .radarTargetTotalCount)
		try accumulator.accumulate(date: date.plus(5), value: 1, type: .radarTargetTotalCount)
		
		accumulator.event(event: .stop, at: date)
		
		config.developerData = AGFitDeveloperData.generateMyBikeTafficDeveloperData(index: 0, from: accumulator)
		let converter = AGFitAcummulatorConverter(config: config,
											   acummulator: accumulator,
											   fitWriter: fitWriter)
		
		
		let result = await converter.convertToFitMessages()
		XCTAssertNil(result)
		
		XCTAssertEqual(fitWriter.messages.count, 12)
		
		let recordMessages = fitWriter.messages.filter { $0 as? RecordMessage != nil }
		XCTAssertEqual(recordMessages.count, 5)
		
		_ = try XCTUnwrap(recordMessages.first)
		
		

		
	}
	
	
	func testFitMessageGenerationRadarDataWithDisconnect() async throws {
		
		let url = try XCTUnwrap(URL.tempFitFile())
		let fitWriter = AGFitWriter(fileURL: url)
		
		var config = AGFitConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road, metric: true)
		let accumulator = AGAccumulator()
		
		let date = Date()
		accumulator.event(event: .start, at: date)

		let radarRanges = AGDataTypeArrayValue(type: .radarRanges, values: [1,2,3,4,5,6,7,8])
		let radarSpeeds = AGDataTypeArrayValue(type: .radarSpeeds, values: [5,5,5,5,5,5,5,5])

		let radarRangesEmpty = AGDataTypeArrayValue(type: .radarRanges, values: [])
		let radarSpeedsEmpty = AGDataTypeArrayValue(type: .radarSpeeds, values: [])
		
		try accumulator.accumulate(date: date.plus(1), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(1), value: 0, type: .radarStatus)
		try accumulator.accumulate(date: date.plus(1), arrayValue: radarRangesEmpty)
		try accumulator.accumulate(date: date.plus(1), arrayValue: radarSpeedsEmpty)
		
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(2), value: 1, type: .radarStatus)
		try accumulator.accumulate(date: date.plus(2), arrayValue: radarRangesEmpty)
		try accumulator.accumulate(date: date.plus(2), arrayValue: radarSpeedsEmpty)

		try accumulator.accumulate(date: date.plus(3), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(3), arrayValue: radarRanges)
		try accumulator.accumulate(date: date.plus(3), arrayValue: radarSpeeds)

		try accumulator.accumulate(date: date.plus(4), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(4), arrayValue: radarRanges)
		try accumulator.accumulate(date: date.plus(4), arrayValue: radarSpeeds)

		try accumulator.accumulate(date: date.plus(5), value: 1, type: .speed)
		try accumulator.accumulate(date: date.plus(5), value: 0, type: .radarStatus)
		try accumulator.accumulate(date: date.plus(5), arrayValue: radarRangesEmpty)
		try accumulator.accumulate(date: date.plus(5), arrayValue: radarSpeedsEmpty)

		accumulator.event(event: .stop, at: date)

		config.developerData = AGFitDeveloperData.generateMyBikeTafficDeveloperData(index: 0, from: accumulator)
		let converter = AGFitAcummulatorConverter(config: config,
												  acummulator: accumulator,
												  fitWriter: fitWriter)
		
		
		let result = await converter.convertToFitMessages()
		XCTAssertNil(result)
		
		XCTAssertEqual(fitWriter.messages.count, 12)
		
		// Now actually write file
		let writeResult = fitWriter.write()
		XCTAssertNil(writeResult)
		
		let fitFileReader2 = AGFitReader(fileUrl: url)
		fitFileReader2.read()
		let messageCount2 = fitFileReader2.messages.count
		
		XCTAssertEqual(messageCount2, 13)

		
		let recordMessages = fitFileReader2.messages.filter { $0 as? RecordMessage != nil }
		XCTAssertEqual(recordMessages.count, 5)
		
		let firstRecordMessage = try XCTUnwrap(recordMessages.first)
		
		var devField = firstRecordMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "radar_ranges")
		var notConnectedValues = try XCTUnwrap(devField.value as? [Int16])
		let compareValues: [Int16] = [255, 255, 255, 255, 255, 255, 255, 255]
		XCTAssertEqual(notConnectedValues, compareValues)
		
		devField = firstRecordMessage.developerValues[1]
		XCTAssertEqual(devField.fieldName, "radar_speeds")
		var speedsNotConnectedValues = try XCTUnwrap(devField.value as? [UInt8])
		let speedsCompareValues: [UInt8] = [255, 255, 255, 255, 255, 255, 255, 255]
		XCTAssertEqual(speedsNotConnectedValues, speedsCompareValues)
	
		
		let secondRecordMessage = try XCTUnwrap(recordMessages[1])

		devField = secondRecordMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "radar_ranges")
		let noRangesValues = try XCTUnwrap(devField.value as? [Int16])
		let noRangesValuesCompare: [Int16] = [0, 0, 0, 0, 0, 0, 0, 0]
		XCTAssertEqual(noRangesValues, noRangesValuesCompare)
		
		devField = secondRecordMessage.developerValues[1]
		XCTAssertEqual(devField.fieldName, "radar_speeds")
		let noSpeedValues = try XCTUnwrap(devField.value as? [UInt8])
		let noSpeedValuesCompare: [UInt8] = [0, 0, 0, 0, 0, 0, 0, 0]
		XCTAssertEqual(noSpeedValues, noSpeedValuesCompare)
		
		
		let thirdRecordMessage = try XCTUnwrap(recordMessages[2])
		
		devField = thirdRecordMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "radar_ranges")
		let rangesValues = try XCTUnwrap(devField.value as? [Int16])
		let rangesValuesCompare: [Int16] = [1,2,3,4,5,6,7,8]
		XCTAssertEqual(rangesValues, rangesValuesCompare)
		
		devField = thirdRecordMessage.developerValues[1]
		XCTAssertEqual(devField.fieldName, "radar_speeds")
		let speedValues = try XCTUnwrap(devField.value as? [UInt8])
		let speedValuesCompare: [UInt8] = [5,5,5,5,5,5,5,5]
		XCTAssertEqual(speedValues, speedValuesCompare)
		
		let fifthRecordMessage = try XCTUnwrap(recordMessages[4])
		
		devField = fifthRecordMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "radar_ranges")
		notConnectedValues = try XCTUnwrap(devField.value as? [Int16])
		XCTAssertEqual(notConnectedValues, compareValues)
		
		devField = fifthRecordMessage.developerValues[1]
		XCTAssertEqual(devField.fieldName, "radar_speeds")
		speedsNotConnectedValues = try XCTUnwrap(devField.value as? [UInt8])
		XCTAssertEqual(speedsNotConnectedValues, speedsCompareValues)
		
		try? FileManager.default.removeItem(at: url)

	}
}





class MockAGFitWriter: AGFitWriter {
	
	override func write() -> AGFitWriterError? {
		return nil
	}
}
