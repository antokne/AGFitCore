//
//  AGFitSession.swift
//  FitViewer
//
//  Created by Antony Gardiner on 16/07/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import Foundation
import AGCore
import FitDataProtocol

enum AGPowerMetric: Int {
	case TSS
	case IF
	case NP
	case KJ
	case VI
	case FTP
}

public class AGFitSessionViewModel: NSObject {
	
	private var formatter = AGFormatter.sharedFormatter
	
	private var startDate: Date = Date()
	
	private var duration: NSNumber = NSNumber(floatLiteral: 0)
	private var distance: NSNumber = NSNumber(floatLiteral: 0)
	
	
	private var speed = AGAverageTypeStruct()
	private var cadence = AGAverageTypeStruct()
	private var power = AGAverageTypeStruct()
	private var heartrate = AGAverageTypeStruct()
	private var calories = AGAverageTypeStruct()
	private var elevation = AGAverageTypeStruct()
	
	private var powerMetrics = [AGPowerMetric: Double]()
	
	public var isValid: Bool {
		return duration.doubleValue > 0
	}
	
	// MARK: - Info
	public var productNameFormatted: String {
		return "?"
	}
	
	public var elemntBatteryUsageFormatted: String {
		return "?"
	}
	
	// MARK: - Date/Time
	public var startDateFormatted: String {
		return formatter.formatDate(date: startDate)
	}
	
	public var startTimeFormatted: String {
		return formatter.formatTime(date: startDate)
	}
	
	public var sportName: String?
	
	// MARK: - Duration
	public var durationFormatted: String {
		return self.formatter.formatDuration(duration: duration.doubleValue)
	}
	
	// MARK: - Distance
	public var distanceFormatted: String {
		return formatter.formatValue(value: distance.doubleValue, using:UnitLength.meters, usingProvidedUnit: false, withDecimalPoints: 1)
	}
	
	// MARK: - Speed
	public var avgSpeedFormatted: String {
		guard let avgSpeed = speed.get(valueForaverageType: .average) else {
			return "?"
		}
		return formatter.formatValue(value: avgSpeed, using: UnitSpeed.metersPerSecond, usingProvidedUnit: false, withDecimalPoints: 2)
	}
	
	public var maxSpeedFormatted: String {
		guard let maxSpeed = speed.get(valueForaverageType: .max) else {
			return "?"
		}
		return formatter.formatValue(value: maxSpeed, using: UnitSpeed.metersPerSecond, usingProvidedUnit: false, withDecimalPoints: 0)
	}
	
	// MARK: - Cadence
	public var avgCadenceFormatted: String {
		guard let value = cadence.get(valueForaverageType: .average) else {
			return "?"
		}
		return formatter.formatValue(value: value, using: AGUnitRevolutions.rpm, usingProvidedUnit: true, withDecimalPoints: 0)
	}
	
	public var maxCadenceFormatted: String {
		guard let value = cadence.get(valueForaverageType: .max) else {
			return "?"
		}
		return formatter.formatValue(value: value, using: AGUnitRevolutions.rpm, usingProvidedUnit: true, withDecimalPoints: 0)
	}
	
	// MARK: - Power
	public var avgPowerFormatted: String {
		guard let value = power.get(valueForaverageType: .average) else {
			return "?"
		}
		return formatter.formatValue(value: value, using: UnitPower.watts, usingProvidedUnit: false, withDecimalPoints: 0)
	}
	
	public var maxPowerFormatted: String {
		guard let value = power.get(valueForaverageType: .max) else {
			return "?"
		}
		return formatter.formatValue(value: value, using: UnitPower.watts, usingProvidedUnit: false, withDecimalPoints: 0)
	}
	
	// MARK: - Heart rate
	public var avgHeartrateFormatted: String {
		guard let value = heartrate.get(valueForaverageType: .average) else {
			return "?"
		}
		return formatter.formatValue(value: value, using: AGUnitHeartrate.bpm, usingProvidedUnit: true, withDecimalPoints: 0)
	}
	
	public var maxHeartrateFormatted: String {
		guard let value = heartrate.get(valueForaverageType: .max) else {
			return "?"
		}
		return formatter.formatValue(value: value, using: AGUnitHeartrate.bpm, usingProvidedUnit: true, withDecimalPoints: 0)
	}
	
	public var caloriesFormatted: String {
		guard let value = calories.get(valueForaverageType: .accumulation) else {
			return "?"
		}
		return formatter.formatValue(value: value, using: UnitEnergy.kilocalories, usingProvidedUnit: true, withDecimalPoints: 0)
	}
	
	// MARK: - Power metrics
	public var thresholdPowerFormatted: String {
		guard let value = self.powerMetrics[.FTP] else {
			return "?"
		}
		return formatter.formatValue(value: value, using: UnitPower.watts, usingProvidedUnit: false, withDecimalPoints: 0)
	}
	
	public var tssFormatted: String {
		guard let value = self.powerMetrics[.TSS] else {
			return "?"
		}
		return formatter.formatValue(value: value, using: AGUnitNone.none, usingProvidedUnit: false, withDecimalPoints: 0)
	}
	
	public var ifFormatted: String {
		guard let value = self.powerMetrics[.IF] else {
			return "?"
		}
		return formatter.formatValue(value: value, using: AGUnitNone.none, usingProvidedUnit: false, withDecimalPoints: 2)
	}
	
	public var npFormatted: String {
		guard let value = self.powerMetrics[.NP] else {
			return "?"
		}
		return formatter.formatValue(value: value, using: UnitPower.watts, usingProvidedUnit: false, withDecimalPoints: 0)
	}
	
	public var kjFormatted: String {
		guard let value = self.powerMetrics[.KJ] else {
			return "?"
		}
		return formatter.formatValue(value: value, using: UnitEnergy.kilojoules, usingProvidedUnit: true, withDecimalPoints: 0)
	}
	
	public var viFormatted: String {
		guard let vi = self.powerMetrics[.VI] else {
			return "?"
		}
		return formatter.formatValue(value: vi, using: AGUnitNone.none, usingProvidedUnit: false, withDecimalPoints: 2)
	}
	
	public var ascentFormatted: String {
		if let ascent = self.elevation.get(valueForaverageType: .accumulation) {
			return formatter.formatValue(value: ascent, using: UnitLength.meters, usingProvidedUnit: true, withDecimalPoints: 0)
		}
		return "?"
	}
	
	// MARK: - init
	public init(with session: SessionMessage) {
		super.init()
		self.startDate = session.startTime?.recordDate ?? Date()
		
		sportName = session.sport?.stringValue
		
		if let value = session.totalTimerTime?.value {
			self.duration = value as NSNumber
		}
		
		if let value = session.totalDistance?.value {
			self.distance = value as NSNumber
		}
		
		if let value = session.averageSpeed?.value {
			speed.set(avgType: .average, value: value)
		}
		if let value = session.maximumSpeed?.value {
			speed.set(avgType: .max, value: value)
		}
		
		if let value = session.averageCadence?.value {
			cadence.set(avgType: .average, value: value)
		}
		if let value = session.maximumCadence?.value {
			cadence.set(avgType: .max, value: value)
		}
		
		if let value = session.averageHeartRate?.value {
			heartrate.set(avgType: .average, value: value)
		}
		if let value = session.maximumHeartRate?.value {
			heartrate.set(avgType: .max, value: value)
		}
		
		if let value = session.averagePower?.value {
			power.set(avgType: .average, value: value)
		}
		if let value = session.maximumPower?.value {
			power.set(avgType: .max, value: value)
		}
		
		if let value = session.totalCalories?.value {
			calories.set(avgType: .accumulation, value: value)
		}
		
		
		if let value = session.trainingStressScore?.value {
			self.powerMetrics[.TSS] = value
		}
		if let value = session.intensityFactor?.value {
			self.powerMetrics[.IF] = value
		}
		if let value = session.normalizedPower?.value {
			self.powerMetrics[.NP] = value
		}
		if let value = session.totalWork?.value {
			self.powerMetrics[.KJ] = value / 1000 // j -> kj
		}
		
		// Cal VI - calulated by deviding NP with avg P
		if let np = self.powerMetrics[.NP], let avgPower = session.averagePower?.value {
			self.powerMetrics[.VI] = np / avgPower
		}
		
		if let ftp = session.thresholdPower?.value {
			self.powerMetrics[.FTP] = ftp
		}
		
		if let ascent = session.totalAscent?.value {
			self.elevation.set(avgType: .accumulation, value: ascent)
		}
	}
	
}
