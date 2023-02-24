//
//  SessionMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 7/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension SessionMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"Session"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let timestamp = timeStamp?.recordDate?.timeIntervalSince1970 {
			result.append(NameValueUnitType(name: "timestamp", value: "\(Int(timestamp))", unit: "s"))
		}
		if let startTime = startTime?.recordDate {
			result.append(NameValueUnitType(name: "startTime", value: "\(formatter.formatDate(date: startTime)) \(formatter.formatTime(date: startTime))"))
		}
		if let totalTimerTime {
			result.append(NameValueUnitType(name: "total", value: formatter.formatDuration(duration: totalTimerTime.value)))
		}
		if let totalElapsedTime {
			result.append(NameValueUnitType(name: "elapsed", value: formatter.formatDuration(duration: totalElapsedTime.value)))
		}
		if let totalMovingTime {
			result.append(NameValueUnitType(name: "moving", value: formatter.formatDuration(duration: totalMovingTime.value)))
		}
		if let sport {
			result.append(NameValueUnitType(name: "sport", value: "\(sport.rawValue) \(sport.stringValue)"))
		}
		if let subSport {
			result.append(NameValueUnitType(name: "subSport", value: "\(subSport.rawValue) \(subSport.stringValue)"))
		}
		if let totalWork {
			result.append(NameValueUnitType(name: "wrk", value: formatter.formatUnitValue(measurement: totalWork)))

		}
		
		let timeInPowerZones = timeInPowerZone
		result.append(NameValueUnitType(name: "TimeInPwrZone", value: ""))
		for (i, powerZone)  in timeInPowerZones.enumerated() {
			result.append(NameValueUnitType(name: "\(i + 1) ", value: formatter.formatDuration(duration: powerZone.value)))
		}
		
		let timeInHeartrateZones = timeInHrZone
		result.append(NameValueUnitType(name: "TimeInHRZone", value: ""))
		for (i, hrZone)  in timeInHeartrateZones.enumerated() {
			result.append(NameValueUnitType(name: "\(i + 1) ", value: formatter.formatDuration(duration: hrZone.value)))
		}
		if let averageSpeed {
			result.append(NameValueUnitType(name: "avgSpd", value: formatter.formatUnitValue(measurement: averageSpeed)))
		}
		if let maximumSpeed {
			result.append(NameValueUnitType(name: "maxSpd", value: formatter.formatUnitValue(measurement: maximumSpeed)))
		}
		if let averageCadence {
			result.append(NameValueUnitType(name: "avgCad", value: formatter.formatUnitValue(measurement: averageCadence)))

		}
		if let maximumCadence {
			result.append(NameValueUnitType(name: "maxCad", value: formatter.formatUnitValue(measurement: maximumCadence)))
		}
		if let averageHeartRate {
			result.append(NameValueUnitType(name: "avgHR", value: formatter.formatUnitValue(measurement: averageHeartRate)))
		}
		if let maximumHeartRate {
			result.append(NameValueUnitType(name: "maxHR", value: formatter.formatUnitValue(measurement: maximumHeartRate)))
		}
		
		if let averagePower {
			result.append(NameValueUnitType(name: "avgPwr", value: formatter.formatUnitValue(measurement: averagePower)))
		}
		
		if let maximumPower {
			result.append(NameValueUnitType(name: "maxPwr", value: formatter.formatUnitValue(measurement: maximumPower)))
		}
		
		if let normalizedPower {
			result.append(NameValueUnitType(name: "NP", value: formatter.formatUnitValue(measurement: normalizedPower)))
		}

		if let trainingStressScore {
			result.append(NameValueUnitType(name: "TSS", value: formatter.formatUnitValue(measurement: trainingStressScore)))
		}
		
		if let intensityFactor {
			result.append(NameValueUnitType(name: "IF", value: formatter.formatUnitValue(measurement: intensityFactor, withDecimalPoints: 2)))
		}
		
		if let thresholdPower {
			result.append(NameValueUnitType(name: "FTP", value: formatter.formatUnitValue(measurement: thresholdPower)))
		}
		
		if let leftRightBalance {
			result.append(NameValueUnitType(name: "L/R Bal", value: "\(leftRightBalance.percentContribution)"))
		}
		
		if let totalAscent {
			result.append(NameValueUnitType(name: "Asc", value: formatter.formatUnitValue(measurement: totalAscent)))
		}
		
		if let totalDescent {
			result.append(NameValueUnitType(name: "Desc", value: formatter.formatUnitValue(measurement: totalDescent)))
		}
		
		if let minimumAltitude {
			result.append(NameValueUnitType(name: "minAlt", value: formatter.formatUnitValue(measurement: minimumAltitude)))
		}
		
		if let maximumAltitude {
			result.append(NameValueUnitType(name: "maxAlt", value: formatter.formatUnitValue(measurement: maximumAltitude)))
		}
		
		if let maximumPositiveGrade {
			result.append(NameValueUnitType(name: "maxGrd", value: formatter.formatUnitValue(measurement: maximumPositiveGrade)))
		}
		
		if let maximumNegitiveGrade {
			result.append(NameValueUnitType(name: "maxNegGrd", value: formatter.formatUnitValue(measurement: maximumNegitiveGrade)))
		}
		
		if let averageTemperature {
			result.append(NameValueUnitType(name: "avgTemp", value: formatter.formatUnitValue(measurement: averageTemperature)))
		}
		
		if let maximumTemperature {
			result.append(NameValueUnitType(name: "maxTemp", value: formatter.formatUnitValue(measurement: maximumTemperature)))
		}
		
		if let eventType {
			result.append(NameValueUnitType(name: "type", value: eventType.name))
		}


		return result
	}
}
