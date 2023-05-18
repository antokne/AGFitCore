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
	
	var fitFile: URL?
	
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		
		guard let fitFile = Bundle.module.url(forResource: "2022-01-05-12-09-29", withExtension: "fit") else {
			XCTFail("Cannot load fit file for test")
			return
		}
		self.fitFile = fitFile
	}
	
	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testLoadFitFile() throws {
		
		guard let fitFile else {
			XCTFail("No fit file")
			return
		}
		
		XCTAssertTrue(FileManager.default.fileExists(atPath: fitFile.path))
		
		let fitFileReader = AGFitReader(fileUrl: fitFile)
		
		fitFileReader.read()

		XCTAssertEqual(fitFileReader.messages.count, 7435)
		
	}
	
	func testPerformanceLoadFitFile() throws {
		
		guard let fitFile else {
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
	
	func testLoadDevDataRadarMesssages() throws {
		
		guard let fitFile else {
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

		// passing speed
		let passingSpeedField = anotherMessage.developerValues[3]
		XCTAssertEqual(passingSpeedField.fieldName, "passing_speed")

		// passing speed abs
		let passingSpeedAbsField = anotherMessage.developerValues[4]
		XCTAssertEqual(passingSpeedAbsField.fieldName, "passing_speedabs")

		
	}
	
}
