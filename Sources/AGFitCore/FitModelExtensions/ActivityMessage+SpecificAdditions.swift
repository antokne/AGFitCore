//
//  ActivityMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 7/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension ActivityMessage: FitMessageSpecificAdditions {
	
	public var messageName: String {
		"Activity"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let timestamp = timeStamp?.recordDate?.timeIntervalSince1970 {
			result.append(NameValueUnitType(name: "timestamp", value: "\(Int(timestamp))", unit: "s"))
		}
		if let totalTimerTime {
			result.append(NameValueUnitType(name: "total", value: formatter.formatDuration(duration: totalTimerTime.value)))
		}
		if let recordDate = localTimeStamp?.recordDate {
			result.append(NameValueUnitType(name: "local time", value: "\(formatter.formatDate(date: recordDate)) \(formatter.formatTime(date: recordDate))"))
		}
		if let numberOfSessions {
			result.append(NameValueUnitType(name: "NoSessions", value: String(numberOfSessions)))
		}
		if let activity {
			result.append(NameValueUnitType(name: "Activity", value: String(activity.rawValue)))
		}
		if let event {
			result.append(NameValueUnitType(name: "event", value: event.name))
		}
		if let eventType {
			result.append(NameValueUnitType(name: "type", value: eventType.name))
		}
		if let eventGroup {
			result.append(NameValueUnitType(name: "group", value: String(eventGroup)))
		}
		
		return result
	}
	
	public func specificMessageIsValid() -> Bool {
		
		if self.timeStamp?.recordDate == nil {
			return false
		}
		
		return true
	}

	public var specificInvalidReason: String {
		
		var message: String = ""
		
		if self.timeStamp?.recordDate == nil {
			message += "Timestamp is not set. "
		}
		
		if self.totalTimerTime == nil {
			message += "Total time is not set. "
		}
			
		return message
	}
	
}
