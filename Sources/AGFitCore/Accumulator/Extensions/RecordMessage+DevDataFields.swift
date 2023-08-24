//
//  RecordMessage+DevDataFields.swift
//  
//
//  Created by Ant Gardiner on 4/07/23.
//

import Foundation
import FitDataProtocol
import AGCore
import CoreLocation

extension RecordMessage {
	
	static var radarDisconnectedRanges: [Int16] {
		[255, 255, 255, 255, 255, 255, 255, 255]
	}
	
	static var radarNoRanges: [Int16] {
		[0, 0, 0, 0, 0, 0, 0, 0]
	}
	
	static var radarDisconnectedSpeeds: [UInt8] {
		[255, 255, 255, 255, 255, 255, 255, 255]
	}
	
	static var radarNoSpeeds: [UInt8] {
		[0, 0, 0, 0, 0, 0, 0, 0]
	}
	
	func encodeDevDataFields(fieldDescriptionMessages: [FieldDescriptionMessage],
							 rawData: AGAccumulatorRawInstantData,
							 arrayData: AGAccumulatorRawArrayInstantData?) {
		
		// just check developer fields for this message
		let fields = fieldDescriptionMessages.fields(for: RecordMessage.globalMessageNumber())
		for field in fields {
			
			var value: Any? = nil
			
			switch field.definitionNumber {
			case AGFitDeveloperData.RadarRangeFieldId:
				// If we have a disconnect status then insert that.
				if let radarStatus = rawData.value(for: .radarStatus), radarStatus == 0 {
					value = RecordMessage.radarDisconnectedRanges
				}
				else if let doubles: [Double] = arrayData?.values(for: .radarRanges) {
					var tempValue: [Int16] = doubles.map { Int16($0) } // convert to array of correct units and UInt16 as stored.
					while tempValue.count < 8 { tempValue.append(Int16(0)) }
					value = tempValue
				}
				else {
					value = RecordMessage.radarNoRanges
				}
			case AGFitDeveloperData.RadarSpeedFieldId:
				// If we have a disconnect status then insert that.
				if let radarStatus = rawData.value(for: .radarStatus), radarStatus == 0 {
					value = RecordMessage.radarDisconnectedSpeeds
				}
				else if let doubles: [Double] = arrayData?.values(for: .radarSpeeds) {
					var tempValue: [UInt8] = doubles.map { UInt8($0) } // convert to array of correct units and UInt8 as stored.
					while tempValue.count < 8 { tempValue.append(UInt8(0)) }
					value = tempValue
				}
				else {
					value = RecordMessage.radarNoSpeeds
				}
			case AGFitDeveloperData.RadarCountFieldId:
				if let doubleValue = rawData.value(for: .radarTargetTotalCount) {
					value = UInt16(doubleValue)
				}
			case AGFitDeveloperData.RadarPassingSpeedFieldId:
				if let doubleValue = rawData.value(for: .radarPassingSpeed) {
					value = UInt8(doubleValue)
				}
			case AGFitDeveloperData.RadarPassingSpeedAbsFieldId:
				if let doubleValue = rawData.value(for: .radarPassingSpeedAbs) {
					value = UInt8(doubleValue)
				}
				
			default:
				break
			}
			
			if let value {
				self.addDeveloperData(value: value, fieldDescription: field)
			}
		}
		
	}
	
	public var hasRadarValues: Bool {
		
		guard developerValues.count == 5 else {
			return false
		}
		
		let index = Int(AGFitDeveloperData.RadarRangeFieldId)
		let rangesField = developerValues[index]
		
		guard let rangesValues = rangesField.value as? [Int16] else {
			return false
		}

		if rangesValues == RecordMessage.radarDisconnectedRanges {
			return false
		}
		if rangesValues == RecordMessage.radarNoRanges {
			return false
		}
		return true
	}
	
	public func radarRangesNonZeroCount() -> Int {
		
		guard developerValues.count == 5 else {
			return 0
		}
		
		let index = Int(AGFitDeveloperData.RadarRangeFieldId)
		let rangesField = developerValues[index]
		
		guard let rangesValues = rangesField.value as? [Int16] else {
			return 0
		}
		
		let nonZeroValues = rangesValues.compactMap { $0 > 0 ? $0 : nil }
		return nonZeroValues.count
	}
	
	
	public func radarTitle() -> String {
		"Range(\(AGDataType.horizontalAccuracy.units.symbol))\tSpeed(\(AGDataType.speed.displayedDimension.symbol))"
	}
	
	public func radarDescription() -> String? {
	
		guard developerValues.count == 5 else {
			return nil
		}
		
		let rangesField = developerValues[Int(AGFitDeveloperData.RadarRangeFieldId)]
		let speedsField = developerValues[Int(AGFitDeveloperData.RadarSpeedFieldId)]
	
		guard let rangesValues = rangesField.value as? [Int16] else {
			return nil
		}
		
		guard let speedValues = speedsField.value as? [UInt8] else {
			return nil
		}

		var result = ""
		for index in 0..<rangesValues.count {
			if rangesValues[index] == 0 {
				continue
			}
			if index < rangesValues.count {
				result += "\n"
			}
			result += "\(AGDataType.horizontalAccuracy.format(value: Double(rangesValues[index])))\t\t\(AGDataType.speed.format(value: Double(speedValues[index])))"
		}
		
		return result
	}
	
	
	var location: CLLocationCoordinate2D? {
		if let lat = position?.latitude?.converted(to: .degrees).value,
		   let lng = position?.longitude?.converted(to: .degrees).value {
			return CLLocationCoordinate2D(latitude: lat, longitude: lng)
		}
		return nil
	}
	
	func distance(from recordMessage: RecordMessage) -> Double? {
		
		guard let location else {
			return nil
		}
		
		guard let otherlocation = recordMessage.location else {
			return nil
		}
		
		let thisCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
		let otherCLLocation = CLLocation(latitude: otherlocation.latitude, longitude: otherlocation.longitude)
		
		return thisCLLocation.distance(from: otherCLLocation)
	}
}
