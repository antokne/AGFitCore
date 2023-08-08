//
//  AGFitReaderTests.swift
//  
//
//  Created by Antony Gardiner on 18/05/23.
//

import XCTest
@testable import AGFitCore
import FitDataProtocol

final class AGFitReaderTests: XCTestCase {
	
	
	override func setUpWithError() throws {
	}
	
	override func tearDownWithError() throws {
	}
	
	func testLoadFitFile() throws {
		
		guard let fitFile = URL.fitURL(name: "2022-01-05-12-09-29", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()

		XCTAssertEqual(fitFileReader.messages.count, 7435)
		
	}
	
	func testPerformanceLoadFitFile() throws {
		
		guard let fitFile = URL.fitURL(name: "2022-01-05-12-09-29", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		self.measure {
			// Put the code you want to measure the time of here.
			fitFileReader.read()
		}
	}
	
	func testLoadDevDataRadarMesssagesRecordMessage() throws {
		
		guard let fitFile = URL.fitURL(name: "2022-01-05-12-09-29", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()
		
		let devDataMessages = fitFileReader.messages.filter { $0.developerValues.count > 0 }
		XCTAssertTrue(!devDataMessages.isEmpty)

		let recordMessages = devDataMessages.filter { $0 as? RecordMessage != nil }
		XCTAssertTrue(!recordMessages.isEmpty)

		let firstMessage = try XCTUnwrap(recordMessages.first)
		
		var rangesDataField = firstMessage.developerValues[0]
		XCTAssertEqual(rangesDataField.fieldName, "radar_ranges")

		// this is just a record I know has some data...
		let anotherMessage = try XCTUnwrap(recordMessages[153])
		
		
		XCTAssertEqual(anotherMessage.developerValues.count, 5)
		
		// radar ranges
		rangesDataField = anotherMessage.developerValues[0]
		XCTAssertEqual(rangesDataField.fieldName, "radar_ranges")

		let rangesValues = try XCTUnwrap(rangesDataField.value as? [Int16])
		XCTAssertEqual(rangesValues.count, 8)

		// radar speeds
		let speedsField = anotherMessage.developerValues[1]
		XCTAssertEqual(speedsField.fieldName, "radar_speeds")

		let speedValues = try XCTUnwrap(speedsField.value as? [UInt8])
		XCTAssertEqual(speedValues.count, 8)

		// radar current
		let currentField = anotherMessage.developerValues[2]
		XCTAssertEqual(currentField.fieldName, "radar_current")

		let currentFieldValue = try XCTUnwrap(UInt16(currentField.value as? Double ?? Double(UInt16.max)))
		XCTAssertEqual(currentFieldValue, 0)
		
		// passing speed
		let passingSpeedField = anotherMessage.developerValues[3]
		XCTAssertEqual(passingSpeedField.fieldName, "passing_speed")

		let passingSpeedValue = try XCTUnwrap(UInt8(passingSpeedField.value as? Double ?? Double(UInt8.max)))
		XCTAssertEqual(passingSpeedValue, 13)
		
		// passing speed abs
		let passingSpeedAbsField = anotherMessage.developerValues[4]
		XCTAssertEqual(passingSpeedAbsField.fieldName, "passing_speedabs")

		let passingSpeedAbsValue = try XCTUnwrap(UInt8(passingSpeedAbsField.value as? Double ?? 0))
		XCTAssertEqual(passingSpeedAbsValue, 26)

	}

	func testLoadDevDataRadarMesssagesLapRecord() throws {
		
		guard let fitFile = URL.fitURL(name: "2022-01-05-12-09-29", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()
		
		let devDataMessages = fitFileReader.messages.filter { $0.developerValues.count > 0 }
		XCTAssertTrue(!devDataMessages.isEmpty)
		
		// Lap Message
		let lapMessages = devDataMessages.filter { $0 as? LapMessage != nil }
		XCTAssertTrue(!lapMessages.isEmpty)
		
		let lapMessage = try XCTUnwrap(lapMessages.first)
		
		let radarLapField = lapMessage.developerValues[0]
		XCTAssertEqual(radarLapField.fieldName, "radar_lap")
		
		let radarLapValue = try XCTUnwrap(UInt16(radarLapField.value as? Double ?? Double(UInt16.max)))
		XCTAssertEqual(radarLapValue, 257)
	}
	
	func testLoadDevDataRadarMesssagesSessionRecord() throws {
		
		guard let fitFile = URL.fitURL(name: "2022-01-05-12-09-29", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()
		
		let devDataMessages = fitFileReader.messages.filter { $0.developerValues.count > 0 }
		XCTAssertTrue(!devDataMessages.isEmpty)
		
		// Session Message
		let sessionMessages = devDataMessages.filter { $0 as? SessionMessage != nil }
		XCTAssertTrue(!sessionMessages.isEmpty)
		
		let sessionMessage = try XCTUnwrap(sessionMessages.first)
		
		let radarTotalField = sessionMessage.developerValues[0]
		XCTAssertEqual(radarTotalField.fieldName, "radar_total")
		
		let radarTotalValue = try XCTUnwrap(UInt16(radarTotalField.value as? Double ?? Double(UInt16.max)))
		XCTAssertEqual(radarTotalValue, 257)
	}
	
	func testRadarDevDataFieldsRecorded() throws {
		
		guard let fitFile = URL.fitURL(name: "2023-06-21-111726-Stradale", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()

		let devDataMessages = fitFileReader.messages.filter { $0.developerValues.count > 0 }
		XCTAssertTrue(!devDataMessages.isEmpty)
		
		let recordMessages = devDataMessages.filter { $0 as? RecordMessage != nil }
		XCTAssertTrue(!recordMessages.isEmpty)
		
		// this is just a record I know has some data...
		let anotherMessage = try XCTUnwrap(recordMessages[24])
		
		// radar ranges
		let rangesDataField = anotherMessage.developerValues[0]
		XCTAssertEqual(rangesDataField.fieldName, "radar_ranges")
		
		let rangesValues = try XCTUnwrap(rangesDataField.value as? [Int16])
		XCTAssertEqual(rangesValues.count, 8)
		
	}
	
	func testRadarDevDataFieldsValidate() throws {
		
		guard let fitFile = URL.fitURL(name: "2023-06-23-164718-Veloscope", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()
		
		let devDataMessages = fitFileReader.messages.filter { $0.developerValues.count > 0 }
		XCTAssertTrue(!devDataMessages.isEmpty)
		
		let recordMessages = devDataMessages.filter { $0 as? RecordMessage != nil }
		XCTAssertTrue(!recordMessages.isEmpty)
		
		
		for message in recordMessages {
			
			
			let rangesDataField = message.developerValues[0]
			_ = try XCTUnwrap(rangesDataField.fieldName)
			let rangesValues = try XCTUnwrap(rangesDataField.value as? [Int16])
			XCTAssertEqual(rangesValues.count, 8)
			
			//print("\(rangesName): \(rangesValues)")
			
			let speedDataField = message.developerValues[1]
			let speedName = try XCTUnwrap(speedDataField.fieldName)
			let speedValues = try XCTUnwrap(speedDataField.value as? [UInt8])
			XCTAssertEqual(speedValues.count, 8)
			
			print("\(speedName): \(speedValues)")

			let passingSpeedDataField = message.developerValues[2]
			_ = try XCTUnwrap(passingSpeedDataField.fieldName)
			_ = try XCTUnwrap(passingSpeedDataField.value as? Double)

			//print("\(passingSpeedName): \(passingSpeed)")

			
			let passingSpeedAbsDataField = message.developerValues[3]
			_ = try XCTUnwrap(passingSpeedAbsDataField.fieldName)
			_ = try XCTUnwrap(passingSpeedAbsDataField.value as? Double)
			
			//print("\(passingSpeedAbsName): \(passingSpeedAbs)")

			let radarCurrentDataField = message.developerValues[4]
			_ = try XCTUnwrap(radarCurrentDataField.fieldName)
			_ = try XCTUnwrap(radarCurrentDataField.value as? Double)
			
			//print("\(radarCurrentName): \(radarCurrent)")

		}
		
	
		
	}
	
	
	func testRadarDevDataFieldsDisconnected() throws {
		
		guard let fitFile = URL.fitURL(name: "radar-disconnected", ext: "fit") else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()
		
		let devDataMessages = fitFileReader.messages.filter { $0.developerValues.count > 0 }
		XCTAssertTrue(!devDataMessages.isEmpty)
		
		let recordMessages = try XCTUnwrap(devDataMessages.filter { $0 as? RecordMessage != nil } as? [RecordMessage])
		XCTAssertTrue(!recordMessages.isEmpty)
		
		
		for message in recordMessages {
			
			
			let rangesDataField = message.developerValues[0]
			let rangesName = try XCTUnwrap(rangesDataField.fieldName)
			let rangesValues = try XCTUnwrap(rangesDataField.value as? [Int16])
			XCTAssertEqual(rangesValues.count, 8)
			
			print("\(rangesName): \(rangesValues)")
			
			let speedDataField = message.developerValues[1]
			let speedName = try XCTUnwrap(speedDataField.fieldName)
			let speedValues = try XCTUnwrap(speedDataField.value as? [UInt8])
			XCTAssertEqual(speedValues.count, 8)
			
			print("\(speedName): \(speedValues)")
			
			if message.developerValues.count == 2 {
				XCTAssertEqual(rangesValues, RecordMessage.radarDisconnectedRanges)
				XCTAssertEqual(speedValues, RecordMessage.radarDisconnectedSpeeds)
			}
			
			if message.developerValues.count == 5 {
				
				let passingSpeedDataField = message.developerValues[2]
				let passingSpeedName = try XCTUnwrap(passingSpeedDataField.fieldName)
				let passingSpeed = try XCTUnwrap(passingSpeedDataField.value as? Double)
				
				print("\(passingSpeedName): \(passingSpeed)")

				let passingSpeedAbsDataField = message.developerValues[3]
				let passingSpeedAbsName = try XCTUnwrap(passingSpeedAbsDataField.fieldName)
				let passingSpeedAbs = try XCTUnwrap(passingSpeedAbsDataField.value as? Double)
				
				print("\(passingSpeedAbsName): \(passingSpeedAbs)")
				
				let radarCurrentDataField = message.developerValues[4]
				let radarCurrentName = try XCTUnwrap(radarCurrentDataField.fieldName)
				let radarCurrent = try XCTUnwrap(radarCurrentDataField.value as? Double)
				
				print("\(radarCurrentName): \(radarCurrent)")
			}
		}
		
		
		
	}
	
}
