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
	
	public var secondsFromGMT: TimeInterval {
		
		guard let timestamp else {
			return 0
		}
		
		guard let timeInterval = localTime?.timeIntervalSince(timestamp) else {
			return 0
		}

		return timeInterval
	}
	
	public var localTimeZone: TimeZone? {
		TimeZone(secondsFromGMT: Int(secondsFromGMT))
	}
	
	
	public init(with activity: ActivityMessage) {
		
		timestamp = activity.timeStamp?.recordDate
		localTime = activity.localTimeStamp?.recordDate
		
		super.init()
		
		// Update the time zone.
		AGFormatter.sharedFormatter.timeZone = localTimeZone ?? .current
		
	}
}
