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
		
		let config = AGConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road)
		let accumulator = AGAccumulator()
		
		var fieldDescriptionMessages: [FieldDescriptionMessage] = []
		let converter = AGAcummulatorConverter(config: config,
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
		
		let config = AGConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road)
		let accumulator = AGAccumulator()
		
		let date = Date()
		accumulator.event(event: .start, at: date)
		accumulator.event(event: .stop, at: date)
		
		let converter = AGAcummulatorConverter(config: config,
											   acummulator: accumulator,
											   fitWriter: fitWriter)
		
	
		let result = await converter.convert()
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
		
		let config = AGConverterConfig(name: "Road Cycling", sport: .cycling, subSport: .road)
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
		
		let converter = AGAcummulatorConverter(config: config,
											   acummulator: accumulator,
											   fitWriter: fitWriter)
		
		
		let result = await converter.convert()
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
		XCTAssertEqual(lapMessage.totalTimerTime?.value, 15)
		XCTAssertEqual(lapMessage.totalElapsedTime?.value, 10)
		XCTAssertEqual(lapMessage.totalDistance?.value, 10)
		XCTAssertEqual(lapMessage.eventType, EventType.stop)
		
		
		// session message
		let sessionMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? SessionMessage) != nil }) as? SessionMessage)
		timeInterval = try XCTUnwrap(sessionMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(lastRecordMessageDate.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(sessionMessage.totalTimerTime?.value, 15)
		XCTAssertEqual(sessionMessage.totalElapsedTime?.value, 10)
		XCTAssertEqual(sessionMessage.totalDistance?.value, 10)
		XCTAssertEqual(sessionMessage.sport, Sport.cycling)
		XCTAssertEqual(sessionMessage.subSport, SubSport.road)
		XCTAssertEqual(sessionMessage.eventType, EventType.stop)
		
		// activity message
		let activityMessage = try XCTUnwrap(fitWriter.messages.first(where: { ($0 as? ActivityMessage) != nil }) as? ActivityMessage)
		timeInterval = try XCTUnwrap(activityMessage.timeStamp?.recordDate?.timeIntervalSinceReferenceDate)
		XCTAssertEqual(lastRecordMessageDate.timeIntervalSinceReferenceDate, timeInterval, accuracy: 1)
		XCTAssertEqual(activityMessage.event, Event.activity)
		XCTAssertEqual(activityMessage.numberOfSessions, 1)
		XCTAssertEqual(activityMessage.activity, Activity.manual)
		XCTAssertEqual(activityMessage.eventType, EventType.stop)
		XCTAssertEqual(activityMessage.totalTimerTime?.value, 15)
	}
}


class MockAGFitWriter: AGFitWriter {
	
	override func write() -> AGFitWriterError? {
		return nil
	}
}
