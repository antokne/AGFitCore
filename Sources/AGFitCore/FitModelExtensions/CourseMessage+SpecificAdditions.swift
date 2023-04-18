//
//  CourseMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 8/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension CourseMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"Course"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let name {
			result.append(NameValueUnitType(name: "Name", value: name))
		}
		if let capabilities {
			result.append(NameValueUnitType(name: "Capabilities", value: "\(capabilities.rawValue)"))
		}
		if let sport {
			result.append(NameValueUnitType(name: "sport", value: "\(sport.rawValue) \(sport.stringValue)"))
		}
		if let subSport {
			result.append(NameValueUnitType(name: "subSport", value: "\(subSport.rawValue) \(subSport.stringValue)"))
		}
		
		return result
	}
	
	public func specificMessageIsValid() -> Bool {
		true
	}

	public var specificInvalidReason: String {
		var message: String = ""
		
		return message
	}
}
