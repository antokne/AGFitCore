//
//  AGFitWriterTests.swift
//  
//
//  Created by Antony Gardiner on 22/05/23.
//

import XCTest
import FitDataProtocol
import AntMessageProtocol
@testable import AGFitCore

final class AGFitWriterTests: XCTestCase {
	
	
	override func setUpWithError() throws {
		
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testAddMessage() {
		
		let url = URL.tempFitFile()
		guard let url else {
			XCTFail("no temp fit file")
			return
		}
		let fitWriter = AGFitWriter(fileURL: url)
		
		let deviceIdMessage = DeviceInfoMessage()
		
		fitWriter.appendMessage(message: deviceIdMessage)
		XCTAssertEqual(1, fitWriter.messages.count)
	}
	
	func testAddMessages() {
		
		let url = URL.tempFitFile()
		guard let url else {
			XCTFail("no temp fit file")
			return
		}
		let fitWriter = AGFitWriter(fileURL: url)
		
		let deviceIdMessages = [DeviceInfoMessage(), DeviceInfoMessage(), DeviceInfoMessage(), DeviceInfoMessage()]
		
		fitWriter.appendMessages(messages: deviceIdMessages)
		XCTAssertEqual(4, fitWriter.messages.count)
	}
	
	func testWriteFit() throws {
		
		guard let fitFile = URL.fitURL(name: "2022-01-05-12-09-29", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		// load fit...
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		fitFileReader.read()
		
		let messageCount = fitFileReader.messages.count
		
		// write new fit.
		
		let url = URL.tempFitFile()
		guard let url else {
			XCTFail("no temp fit file")
			return
		}
		let fitWriter = AGFitWriter(fileURL: url)
		
		fitWriter.appendMessages(messages: fitFileReader.messages)
		XCTAssertEqual(messageCount, fitWriter.messages.count)
		
		
		let result = fitWriter.write()
		XCTAssertNil(result)
		
		// Read it back
		let fitFileReader2 = AGFitReader(fileUrl: url)
		fitFileReader2.read()
		let messageCount2 = fitFileReader2.messages.count
		
		XCTAssertEqual(messageCount, messageCount2)
		
		// clean up
		try? FileManager.default.removeItem(at: url)
	}
	
	func testWriteDevDataFields() throws {
		
		
		let fileIdMesage = FileIdMessage(deviceSerialNumber: 34353535,
										 fileCreationDate: FitTime(date: Date()),
										 manufacturer: Manufacturer.unknown,
										 fileType: FileType.activity,
										 productName: "Bob")
		let developerDataId = DeveloperDataIdMessage(dataIndex: 0)
		
		let fieldDescription = FieldDescriptionMessage(dataIndex: 0,
													   definitionNumber: 0,
													   fieldName: "Test field 1",
													   baseInfo: BaseTypeData(type: .uint8),
													   units: "g",
													   baseUnits: BaseUnitType.other,
													   messageNumber: 20,
													   fieldNumber: nil)
		
		let recordMessage = RecordMessage(timeStamp: FitTime(date: Date()))
		let value = UInt8(8)
		XCTAssertTrue(recordMessage.addDeveloperData(value: value, fieldDescription: fieldDescription))
		
		guard let tempFiturl = URL.tempFitFile() else {
			XCTFail("no temp fit file")
			return
		}
		
		let fitWriter = AGFitWriter(fileURL: tempFiturl)
		fitWriter.appendMessage(message: fileIdMesage)
		fitWriter.appendDeveloperDataId(developerDataID: developerDataId)
		fitWriter.appendFieldDescription(fieldDescription: fieldDescription)
		
		fitWriter.appendMessage(message: recordMessage)
		
		let result = fitWriter.write()
		XCTAssertNil(result)
		
		// We have a small issue here as the loading of this will not return the field description messages.
		
		// Read it back
		let fitFileReader2 = AGFitReader(fileUrl: tempFiturl)
		fitFileReader2.read()
		let messageCount2 = fitFileReader2.messages.count
		
		XCTAssertEqual(3, messageCount2)
		
		let recordMessages = fitFileReader2.messages.filter { $0 as? RecordMessage != nil }
		XCTAssert(recordMessages.count == 1)
		
		let loadedRecordMessage = recordMessages[0]
		XCTAssertEqual(loadedRecordMessage.developerValues.count, 1)
		
		let devField = loadedRecordMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "Test field 1")
		let loadedValue = try XCTUnwrap(devField.value as? Double)
		XCTAssertEqual(loadedValue, 8)
		
		try? FileManager.default.removeItem(at: tempFiturl)
		
	}
	
	
	func testWriteRadarDevDataFields() throws {
		
		let fileIdMesage = FileIdMessage(deviceSerialNumber: 34353535,
										 fileCreationDate: FitTime(date: Date()),
										 manufacturer: Manufacturer.unknown,
										 fileType: FileType.activity,
										 productName: "Bob")
		let developerDataId = DeveloperDataIdMessage(dataIndex: 0)
		
		var fields = RecordMessage.fieldDesciptionMessages()
		let radarRangesField = fields[0]
		let radarSpeedsField = fields[1]
		let radarCurrentField = fields[2]
		let passingSpeedField = fields[3]
		let passingSpeedAbsField = fields[4]
		
		let radarTotalField = FieldDescriptionMessage(dataIndex: 0,
													  definitionNumber: 3,
													  fieldName: "radar_total",
													  baseInfo: BaseTypeData(type: .uint16),
													  units: nil,
													  baseUnits: nil,
													  messageNumber: 18,
													  fieldNumber: nil)
		
		let radarLapField = FieldDescriptionMessage(dataIndex: 0,
													definitionNumber: 4,
													fieldName: "radar_lap",
													baseInfo: BaseTypeData(type: .uint16),
													units: nil,
													baseUnits: nil,
													messageNumber: 19,
													fieldNumber: nil)
		fields.append(radarTotalField)
		fields.append(radarLapField)
		
		// -37.773218, 175.287636
		let lat = Measurement(value: -37.773218, unit: UnitAngle.degrees)
		let lng = Measurement(value: 175.287636, unit: UnitAngle.degrees)
		let recordMessage = RecordMessage(timeStamp: FitTime(date: Date()), position: Position(latitude: lat, longitude: lng))
		
		let rangeValues: [Int16] = [23, 34, 0, 0, 0, 0, 0, 0]
		XCTAssertTrue(recordMessage.addDeveloperData(value: rangeValues, fieldDescription: radarRangesField))
		
		let speedValues: [UInt8] = [50, 55, 0, 0, 0, 0, 0, 0]
		XCTAssertTrue(recordMessage.addDeveloperData(value: speedValues, fieldDescription: radarSpeedsField))

		let currentValue: UInt16 = 2
		XCTAssertTrue(recordMessage.addDeveloperData(value: currentValue, fieldDescription: radarCurrentField))

		let passingSpeed: UInt8 = 24
		XCTAssertTrue(recordMessage.addDeveloperData(value: passingSpeed, fieldDescription: passingSpeedField))

		let passingSpeedAbs: UInt8 = 20
		XCTAssertTrue(recordMessage.addDeveloperData(value: passingSpeedAbs, fieldDescription: passingSpeedAbsField))

		let fitTime = FitTime(date: Date())
		
		let lapMessage = LapMessage(timeStamp: fitTime, startTime: fitTime)
		let radarLapTotalValue: UInt16 = 56
		XCTAssertTrue(lapMessage.addDeveloperData(value: radarLapTotalValue, fieldDescription: radarLapField))
		
		let sessionMessage = SessionMessage(timeStamp: fitTime, startTime: fitTime)
		let radarTotalValue: UInt16 = 120
		XCTAssertTrue(sessionMessage.addDeveloperData(value: radarTotalValue, fieldDescription: radarTotalField))
		
		guard let tempFiturl = URL.tempFitFile() else {
			XCTFail("no temp fit file")
			return
		}
		
		
		let fitWriter = AGFitWriter(fileURL: tempFiturl)
		fitWriter.appendMessage(message: fileIdMesage)
		fitWriter.appendDeveloperDataId(developerDataID: developerDataId)
		
		for field in fields {
			fitWriter.appendFieldDescription(fieldDescription: field)
		}
		
		fitWriter.appendMessage(message: recordMessage)
		fitWriter.appendMessage(message: lapMessage)
		fitWriter.appendMessage(message: sessionMessage)
		
		let result = fitWriter.write()
		XCTAssertNil(result)
		
		
		// Read it back
		let fitFileReader2 = AGFitReader(fileUrl: tempFiturl)
		fitFileReader2.read()
		let messageCount2 = fitFileReader2.messages.count
		
		XCTAssertEqual(5, messageCount2)
		
		let recordMessages = fitFileReader2.messages.filter { $0 as? RecordMessage != nil }
		XCTAssert(recordMessages.count == 1)
		
		let loadedRecordMessage = recordMessages[0]
		XCTAssertEqual(loadedRecordMessage.developerValues.count, 5)
		
		var devField = loadedRecordMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "radar_ranges")
		let loadedValue1 = try XCTUnwrap(devField.value as? [Int16])
		XCTAssertEqual(loadedValue1, rangeValues)
		
		devField = loadedRecordMessage.developerValues[1]
		XCTAssertEqual(devField.fieldName, "radar_speeds")
		let loadedValue2 = try XCTUnwrap(devField.value as? [UInt8])
		XCTAssertEqual(loadedValue2, speedValues)
		
		devField = loadedRecordMessage.developerValues[2]
		XCTAssertEqual(devField.fieldName, "radar_current")
		let loadedValue3 = try XCTUnwrap(devField.value as? Double) // these coming back as a double shrug...
		XCTAssertEqual(UInt16(loadedValue3), currentValue)

		devField = loadedRecordMessage.developerValues[3]
		XCTAssertEqual(devField.fieldName, "passing_speed")
		let loadedValue4 = try XCTUnwrap(devField.value as? Double) // these coming back as a double shrug...
		XCTAssertEqual(UInt8(loadedValue4), passingSpeed)

		devField = loadedRecordMessage.developerValues[4]
		XCTAssertEqual(devField.fieldName, "passing_speedabs")
		let loadedValue5 = try XCTUnwrap(devField.value as? Double) // these coming back as a double shrug...
		XCTAssertEqual(UInt8(loadedValue5), passingSpeedAbs)
		
		// lap message
		let lapMessages = fitFileReader2.messages.filter { $0 as? LapMessage != nil }
		XCTAssert(lapMessages.count == 1)

		let loadedLapMessage = lapMessages[0]
		XCTAssertEqual(loadedLapMessage.developerValues.count, 1)
		
		devField = loadedLapMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "radar_lap")
		let lapLoadedValue = try XCTUnwrap(devField.value as? Double)
		XCTAssertEqual(UInt16(lapLoadedValue), radarLapTotalValue)

		// lap message
		let sessionMessages = fitFileReader2.messages.filter { $0 as? SessionMessage != nil }
		XCTAssert(sessionMessages.count == 1)
		
		let loadedSessionMessage = sessionMessages[0]
		XCTAssertEqual(loadedSessionMessage.developerValues.count, 1)
		
		devField = loadedSessionMessage.developerValues[0]
		XCTAssertEqual(devField.fieldName, "radar_total")
		let sessionLoadedValue = try XCTUnwrap(devField.value as? Double)
		XCTAssertEqual(UInt16(sessionLoadedValue), radarTotalValue)

		
		try? FileManager.default.removeItem(at: tempFiturl)

	}
}
