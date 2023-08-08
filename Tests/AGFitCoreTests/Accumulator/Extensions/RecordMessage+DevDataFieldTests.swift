//
//  RecordMessage+DevDataFieldTests.swift
//  
//
//  Created by Ant Gardiner on 8/08/23.
//

import XCTest
@testable import FitDataProtocol
@testable import AGCore
@testable import AGFitCore

final class RecordMessage_DevDataFieldTests: XCTestCase {
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testRadarRangeData() throws {
		XCTAssertEqual(RecordMessage.radarDisconnectedRanges, [255,255,255,255,255,255,255,255])
		XCTAssertEqual(RecordMessage.radarNoRanges, [0,0,0,0,0,0,0,0])
	}
	
	func testRadarSpredData() throws {
		XCTAssertEqual(RecordMessage.radarDisconnectedSpeeds, [255,255,255,255,255,255,255,255])
		XCTAssertEqual(RecordMessage.radarNoSpeeds, [0,0,0,0,0,0,0,0])
	}

	func testRecordMessageWithRadarData() throws {
		
		let fieldDescriptionMessages = RecordMessage.fieldDesciptionMessages()
		XCTAssertEqual(fieldDescriptionMessages.count, 5)
		let recordMessage = RecordMessage(timeStamp: FitTime(date: Date()))
		
		var data = AGAccumulatorRawInstantData()
		data.add(value: AGDataTypeValue(type: .radarTargetTotalCount, value: 1))
		data.add(value: AGDataTypeValue(type: .radarPassingSpeed, value: 1))
		data.add(value: AGDataTypeValue(type: .radarPassingSpeedAbs, value: 1))
		var arrayData = AGAccumulatorRawArrayInstantData()
		arrayData.add(value: AGDataTypeArrayValue(type: .radarRanges, values: [1]))
		arrayData.add(value: AGDataTypeArrayValue(type: .radarSpeeds, values: [1]))

		recordMessage.encodeDevDataFields(fieldDescriptionMessages: fieldDescriptionMessages,
										  rawData: data,
										  arrayData: arrayData)

		// Need to encode decode to get dev data fields populated.
		let decodedMessage = try XCTUnwrap(RecordMessage.encodeDecode(message: recordMessage))
		
		
		XCTAssertTrue(decodedMessage.hasRadarValues)
	}
	
	func testRecordMessageNoRadarData() throws {
		
		let fieldDescriptionMessages = RecordMessage.fieldDesciptionMessages()
		XCTAssertEqual(fieldDescriptionMessages.count, 5)
		let recordMessage = RecordMessage(timeStamp: FitTime(date: Date()))
		
		var data = AGAccumulatorRawInstantData()
		data.add(value: AGDataTypeValue(type: .radarTargetTotalCount, value: 1))
		data.add(value: AGDataTypeValue(type: .radarPassingSpeed, value: 1))
		data.add(value: AGDataTypeValue(type: .radarPassingSpeedAbs, value: 1))
		var arrayData = AGAccumulatorRawArrayInstantData()
		arrayData.add(value: AGDataTypeArrayValue(type: .radarRanges, values: []))
		arrayData.add(value: AGDataTypeArrayValue(type: .radarSpeeds, values: []))
		
		recordMessage.encodeDevDataFields(fieldDescriptionMessages: fieldDescriptionMessages,
										  rawData: data,
										  arrayData: arrayData)
		
		// Need to encode decode to get dev data fields populated.
		let decodedMessage = try XCTUnwrap(RecordMessage.encodeDecode(message: recordMessage))
		
		
		XCTAssertFalse(decodedMessage.hasRadarValues)
	}
	
}
