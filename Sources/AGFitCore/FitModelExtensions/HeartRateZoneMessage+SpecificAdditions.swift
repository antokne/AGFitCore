//
//  HeartrateMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 7/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension HeartRateZoneMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"HRZone"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let name {
			result.append(NameValueUnitType(name: "Name", value: name))
		}
		if let messageIndex {
			result.append(NameValueUnitType(name: "index", value: String(messageIndex.index)))
		}
		if let heartRate {
			result.append(NameValueUnitType(name: "High", value:  formatter.formatUnitValue(measurement: heartRate)))
		}
		return result
	}
}
