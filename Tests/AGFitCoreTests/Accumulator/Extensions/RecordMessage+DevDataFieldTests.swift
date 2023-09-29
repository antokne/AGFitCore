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
		
		let metric = Locale.current.measurementSystem == .metric
		let speedCheck = UInt8(metric ? 10 : 6)
		let speedAbsCheck = UInt8(metric ? 18 : 11)
		
		var data = AGAccumulatorRawInstantData()
		data.add(value: AGDataTypeValue(type: .radarTargetTotalCount, value: 1))
		data.add(value: AGDataTypeValue(type: .radarPassingSpeed, value: 3))
		data.add(value: AGDataTypeValue(type: .radarPassingSpeedAbs, value: 5))
		var arrayData = AGAccumulatorRawArrayInstantData()
		arrayData.add(value: AGDataTypeArrayValue(type: .radarRanges, values: [1]))
		arrayData.add(value: AGDataTypeArrayValue(type: .radarSpeeds, values: [1]))

		recordMessage.encodeDevDataFields(fieldDescriptionMessages: fieldDescriptionMessages,
										  rawData: data,
										  arrayData: arrayData)

		// Need to encode decode to get dev data fields populated.
		let decodedMessage = try XCTUnwrap(RecordMessage.encodeDecode(message: recordMessage))
		
		
		XCTAssertTrue(decodedMessage.hasRadarValues)
			
		XCTAssertEqual(decodedMessage.developerValues.count, 5)

		// radar ranges
		var rangesDataField = decodedMessage.developerValues[0]
		XCTAssertEqual(rangesDataField.fieldName, "radar_ranges")
		
		let rangesValues = try XCTUnwrap(rangesDataField.value as? [Int16])
		XCTAssertEqual(rangesValues.count, 8)
		
		// radar speeds
		let speedsField = decodedMessage.developerValues[1]
		XCTAssertEqual(speedsField.fieldName, "radar_speeds")
		
		let speedValues = try XCTUnwrap(speedsField.value as? [UInt8])
		XCTAssertEqual(speedValues.count, 8)
		
		// radar current
		let currentField = decodedMessage.developerValues[2]
		XCTAssertEqual(currentField.fieldName, "radar_current")
		
		let currentFieldValue = try XCTUnwrap(UInt16(currentField.value as? Double ?? Double(UInt16.max)))
		XCTAssertEqual(currentFieldValue, 1)
		
		// passing speed
		let passingSpeedField = decodedMessage.developerValues[3]
		XCTAssertEqual(passingSpeedField.fieldName, "passing_speed")
		
		let passingSpeedValue = try XCTUnwrap(UInt8(passingSpeedField.value as? Double ?? Double(UInt8.max)))
		XCTAssertEqual(passingSpeedValue, speedCheck)
		
		// passing speed abs
		let passingSpeedAbsField = decodedMessage.developerValues[4]
		XCTAssertEqual(passingSpeedAbsField.fieldName, "passing_speedabs")
		
		let passingSpeedAbsValue = try XCTUnwrap(UInt8(passingSpeedAbsField.value as? Double ?? 0))
		XCTAssertEqual(passingSpeedAbsValue, speedAbsCheck)
		
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
