//
//  PowerZoneMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 7/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension PowerZoneMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"PwrZone"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let name {
			result.append(NameValueUnitType(name: "Name", value: name))
		}
		if let messageIndex {
			result.append(NameValueUnitType(name: "index", value: String(messageIndex.index)))
		}
		if let highLevel {
			result.append(NameValueUnitType(name: "High", value:  formatter.formatUnitValue(measurement: highLevel)))
		}
		return result
	}
}
