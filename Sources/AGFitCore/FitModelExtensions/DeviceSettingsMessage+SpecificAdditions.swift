//
//  DeviceSettingsMessage+SpecificAdditions.swift
//
//
//  Created by Ant Gardiner on 27/09/23.
//

import Foundation
import FitDataProtocol

extension DeviceSettingsMessage: FitMessageSpecificAdditions {
	
	public var messageName: String {
		"DeviceSetting"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
//		if let activeTimeZone {
//			result.append(NameValueUnitType(name: "activeTimeZone", value: "\(Int(activeTimeZone))"))
//		}
//		if let utcOffset {
//			result.append(NameValueUnitType(name: "utcOffset", value: "\(utcOffset)"))
//		}
		if let date = clockTime?.recordDate {
			result.append(NameValueUnitType(name: "clockTime", value: "\(date)"))
		}
		return result
	}
	
	public func specificMessageIsValid() -> Bool {
		return true
	}
	
	public var specificInvalidReason: String {
		
		let message: String = ""
		return message
	}
	
}
