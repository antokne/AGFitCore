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

public enum AGFitSmoothableType: Int {
	case speed
	case cadence
	case heartrate
	case power
	case gpsAccuracy
	case altitude
}

protocol AGSmoothableSamples {
	static func smoothedValue(samples: [AGFitSampleViewModel], index: Int, count: Int, type: AGFitSmoothableType) -> Double?
}

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
		
		self.distance = NSNumber(value: record.distance?.value ?? 0)
		self.speed = NSNumber(value: record.speed?.value ?? 0)
		self.cadence = NSNumber(value: record.cadence?.value ?? 0)
		self.heartrate = NSNumber(value: record.heartRate?.value ?? 0)
		self.power = NSNumber(value: record.power?.value ?? 0)
		
		if let lat = record.position?.latitude?.converted(to: .degrees).value,
		   let lng = record.position?.longitude?.converted(to: .degrees).value {
			self.lat = NSNumber(value: lat)
			self.lng = NSNumber(value: lng)
		}
		self.gpsAccuracy = NSNumber(value: record.gpsAccuracy?.value ?? 0)
		self.altitude = NSNumber(value: record.altitude?.value ?? 0)
		super.init()
		
		// os_log("index:%d time:%d", index, self.time)
	}
	
}

extension AGFitSampleViewModel : AGSmoothableSamples {
	
	public static func smoothedValue(samples: [AGFitSampleViewModel], index: Int, count: Int, type: AGFitSmoothableType) -> Double? {
		
		var value = 0.0;
		
		let halfCount = count / 2
		
		var currentIndex = index - halfCount
		if currentIndex < 0 {
			currentIndex = 0
		}
		
		var total = 0.0
		var actualCount = 0.0
		while currentIndex <= index + halfCount {
			
			if currentIndex >= samples.count {
				break
			}
			
			switch type {
			case .speed:
				if let speed = samples[currentIndex].speed {
					total += speed.doubleValue
					actualCount += 1
				}
			case .cadence:
				if let cadence = samples[currentIndex].cadence {
					total += cadence.doubleValue
					actualCount += 1
				}
			case .heartrate:
				if let heartrate = samples[currentIndex].heartrate {
					total += heartrate.doubleValue
					actualCount += 1
				}
			case .power:
				if let power = samples[currentIndex].power {
					total += power.doubleValue
					actualCount += 1
				}
			case .gpsAccuracy:
				if let gpsAcc = samples[currentIndex].gpsAccuracy {
					total += gpsAcc.doubleValue
					actualCount += 1
				}
			case .altitude:
				if let altitude = samples[currentIndex].altitude {
					total += altitude.doubleValue
					actualCount += 1
				}
			}
			
			currentIndex += 1
		}
		
		if actualCount == 0 {
			return nil
		}
		
		value = total / actualCount
		
		// os_log("index:%d type:%d value:%f", index, type.rawValue, value)
		
		return value
	}
}
