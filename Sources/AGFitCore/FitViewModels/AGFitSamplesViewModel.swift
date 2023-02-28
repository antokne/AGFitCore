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

@objc public class AGFitSamplesViewModel: NSObject {
	
	private(set) public var samples: [AGFitSampleViewModel] = []
	
	public var hasValues: [AGFitSmoothableType: Bool] = [:]
	
	private func doesSample(sample: AGFitSampleViewModel, have type: AGFitSmoothableType) -> Bool {
		
		switch type {
		case .speed:
			return sample.speed != nil
		case .cadence:
			return sample.cadence != nil
		case .heartrate:
			return sample.heartrate != nil
		case .power:
			return sample.power != nil
		case .gpsAccuracy:
			return sample.gpsAccuracy != nil
		case .altitude:
			return sample.altitude != nil
		}
	}
	
	public var sampleCount: Int {
		samples.count
	}
	
	public func add(sample: AGFitSampleViewModel) {
		samples.append(sample)
		
		hasValues[.speed] = doesSample(sample: sample, have: .speed) || hasValues[.speed] ?? false
		hasValues[.cadence] = doesSample(sample: sample, have: .cadence) || hasValues[.cadence] ?? false
		hasValues[.heartrate] = doesSample(sample: sample, have: .heartrate) || hasValues[.heartrate] ?? false
		hasValues[.power] = doesSample(sample: sample, have: .power) || hasValues[.power] ?? false
		hasValues[.gpsAccuracy] = doesSample(sample: sample, have: .gpsAccuracy) || hasValues[.gpsAccuracy] ?? false
		hasValues[.altitude] = doesSample(sample: sample, have: .altitude) || hasValues[.altitude] ?? false

	}
	
}

extension AGFitSamplesViewModel : AGSmoothableSamples {
	
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
