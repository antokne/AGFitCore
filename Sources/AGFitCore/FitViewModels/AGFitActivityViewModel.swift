//
//  AGFitActivityViewModel.swift
//
//
//  Created by Ant Gardiner on 26/09/23.
//

import Foundation
import AGCore
import FitDataProtocol

public class AGFitActivityViewModel: NSObject {
	
	private var formatter = AGFormatter.sharedFormatter
	
	var timestamp: Date?
	var localTime: Date?
	
	/// Calculate the timezone offset from GMT using difference between local time and timestamp
	public var secondsFromGMT: TimeInterval {
		
		guard let timestamp else {
			return 0
		}
		
		guard let timeInterval = localTime?.timeIntervalSince(timestamp) else {
			return 0
		}

		return timeInterval
	}
	
	/// Return the timezone for this message
	public var localTimeZone: TimeZone? {
		TimeZone(secondsFromGMT: Int(secondsFromGMT))
	}
	
	/// Init view model with model entity.
	/// - Parameter activity: activity model object
	public init(with activity: ActivityMessage) {
		
		timestamp = activity.timeStamp?.recordDate
		localTime = activity.localTimeStamp?.recordDate
		
		super.init()
		
		// Update the time zone.
		AGFormatter.sharedFormatter.timeZone = localTimeZone ?? .current
		
	}
}
