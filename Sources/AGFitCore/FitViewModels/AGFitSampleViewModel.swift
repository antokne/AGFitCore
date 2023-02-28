//
//  AGFitSample.swift
//  FitViewer
//
//  Created by Antony Gardiner on 16/07/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import os
import Foundation
import AGCore
import FitDataProtocol


@objc public class AGFitSampleViewModel: NSObject {
	
	private var formatter = AGFormatter.sharedFormatter
	
	public var index: Int = 0
	
	public var paused: Bool = false
	
	public var pausedFormatted: String {
		get {
			return paused ? "Yes" : "No"
		}
	}
	
	/// Time in seconds
	public var time: Int = 0
	
	/// Distance in metres
	public var distanceM: Int {
		get {
			if let distance = distance {
				return Int(distance.doubleValue)
			}
			return 0
		}
	}
	
	private var distance: NSNumber?
	
	public var distanceFormatted: String {
		if let distance = distance {
			return formatter.formatValue(value: distance.doubleValue, using:UnitLength.meters, usingProvidedUnit: false, withDecimalPoints: 1)
		}
		return "?"
	}
	
	public var speedFormatted: String {
		if let speed = speed {
			return formatter.formatValue(value: speed.doubleValue, using: UnitSpeed.metersPerSecond, usingProvidedUnit: false, withDecimalPoints: 1)
		}
		return "?"
	}
	
	public var speed: NSNumber?
	public var cadence: NSNumber?
	public var heartrate: NSNumber?
	public var power: NSNumber?
	public var lat: NSNumber?
	public var lng: NSNumber?
	public var gpsAccuracy: NSNumber?
	public var altitude: NSNumber?
	
	static var startTimeInterval = 0
	
	public init(withIndex index:Int, record:RecordMessage) {
		self.index = index
		
		if record is PausedMessage {
			self.paused = true
		}
		
		let timeInterval = Int(record.timeStamp?.recordDate?.timeIntervalSince1970 ?? 0)
		if index == 0 {
			AGFitSampleViewModel.startTimeInterval = timeInterval
		}
		
		self.time = timeInterval - AGFitSampleViewModel.startTimeInterval
		
		if let value = record.distance?.value {
			self.distance = NSNumber(value: value)
		}	
		if let value = record.speed?.value {
			self.speed = NSNumber(value: value)
		}
		if let value = record.cadence?.value {
			self.cadence = NSNumber(value: value)
		}
		if let value = record.heartRate?.value {
			self.heartrate = NSNumber(value: value)
		}
		if let value = record.power?.value {
			self.power = NSNumber(value: value)
		}

		if let lat = record.position?.latitude?.converted(to: .degrees).value,
		   let lng = record.position?.longitude?.converted(to: .degrees).value {
			self.lat = NSNumber(value: lat)
			self.lng = NSNumber(value: lng)
		}

		if let value = record.gpsAccuracy?.value {
			self.gpsAccuracy = NSNumber(value: value)
		}
		if let value = record.altitude?.value {
			self.altitude = NSNumber(value: value)
		}
		
		super.init()
		
		// os_log("index:%d time:%d", index, self.time)
	}
	
}

