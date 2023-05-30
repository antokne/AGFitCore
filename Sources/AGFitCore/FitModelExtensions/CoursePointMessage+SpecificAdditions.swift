//
//  CoursePointMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 8/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension CoursePointMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"CoursePoint"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let timestamp = timeStamp?.recordDate?.timeIntervalSince1970 {
			result.append(NameValueUnitType(name: "timestamp", value: "\(Int(timestamp))", unit: "s"))
		}
		if let pointType {
			result.append(NameValueUnitType(name: "type", value: pointType.stringValue))
		}
		if let name {
			result.append(NameValueUnitType(name: "Name", value: name))
		}
		if let lat = position?.latitude?.converted(to: .degrees).value{
			result.append(NameValueUnitType(name: "lat", value: String(format: "%.4f", lat), unit: "º"))
		}
		if let lon = position?.longitude?.converted(to: .degrees).value {
			result.append(NameValueUnitType(name: "lon", value: String(format: "%.4f", lon), unit: "º"))
		}
		if let distMeasurement = distance {
			result.append(NameValueUnitType(name: "dist", value: formatter.formatUnitValue(measurement: distMeasurement, usingProvidedUnit: false, withDecimalPoints: 0)))
		}
		if let messageIndex {
			result.append(NameValueUnitType(name: "messageIndex", value: "\(messageIndex.index)"))
		}
		
		
		return result
	}
	
	public func specificMessageIsValid() -> Bool {
		true
	}
	
	public var specificInvalidReason: String {
		let message: String = ""
		
		return message
	}

}


extension CoursePoint {
	public var stringValue: String {
		switch self {
		case .generic:
			return "generic"
		case .summit:
			return "summit"
		case .valley:
			return "valley"
		case .water:
			return "water"
		case .food:
			return "food"
		case .danger:
			return "danger"
		case .left:
			return "left"
		case .right:
			return "right"
		case .straight:
			return "straight"
		case .firstAid:
			return "firstAid"
		case .fourthCategory:
			return "fourthCategory"
		case .thirdCategory:
			return "thirdCategory"
		case .secondCategory:
			return "secondCategory"
		case .firstCategory:
			return "firstCategory"
		case .horsCategory:
			return "horsCategory"
		case .sprint:
			return "sprint"
		case .leftFork:
			return "leftFork"
		case .rightFork:
			return "rightFork"
		case .middleFork:
			return "middleFork"
		case .slightLeft:
			return "slightLeft"
		case .sharpLeft:
			return "sharpLeft"
		case .slightRight:
			return "slightRight"
		case .sharpRight:
			return "sharpRight"
		case .uTurn:
			return "uTurn"
		case .segmentStart:
			return "segmentStart"
		case .segmentEnd:
			return "segmentEnd"
		case .invalid:
			return "invalid"
		}
	}
}

