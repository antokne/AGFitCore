//
//  AGFitLap.swift
//  FitViewer
//
//  Created by Antony Gardiner on 23/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import AGCore
import FitDataProtocol


public class AGFitLapViewMode: NSObject {
	
	private var formatter = AGFormatter.sharedFormatter

	private var lapMessage: LapMessage?
	
	public var startTimeFormatted: String? {
		guard let startTime = lapMessage?.startTime?.recordDate else {
			return nil
		}
		return formatter.formatTime(date: startTime)
	}
	
	public var totalTimeFormatted: String? {
		guard let totalTime = lapMessage?.totalTimerTime else {
			return nil
		}
		return formatter.formatDuration(duration: totalTime.value)
	}

	public var distanceFormatted: String? {
		guard let distance = lapMessage?.totalDistance else {
			return nil
		}
		return formatter.formatUnitValue(measurement: distance)
	}
	
	// MARK: - Speed
	public var avgSpeedFormatted: String? {
		guard let avgSpeed = lapMessage?.averageSpeed else {
			return nil
		}
		return formatter.formatSpeedValue(measurement: avgSpeed, usingProvidedUnit: false, withDecimalPoints: 0)
	}
	
	public var maxSpeedFormatted: String? {
		guard let maxSpeed = lapMessage?.maximumSpeed else {
			return nil
		}
		return formatter.formatSpeedValue(measurement: maxSpeed, usingProvidedUnit: false, withDecimalPoints: 0)
	}

	// MARK: - Cadence
	public var avgCadenceFormatted: String? {
		guard let avgCadence = lapMessage?.averageCadence else {
			return nil
		}
		return formatter.formatUnitValue(measurement: avgCadence)
	}
	
	public var maxCadenceFormatted: String? {
		guard let maxCadence = lapMessage?.maximumCadence else {
			return nil
		}
		return formatter.formatUnitValue(measurement: maxCadence)
	}
	
	// MARK: - Power
	public var avgPowerFormatted: String? {
		guard let value = lapMessage?.averagePower else {
			return nil
		}
		return formatter.formatUnitValue(measurement: value)
	}
	
	public var maxPowerFormatted: String? {
		guard let value = lapMessage?.maximumPower else {
			return nil
		}
		return formatter.formatUnitValue(measurement: value)
	}
	
	// MARK: - Heart rate
	public var avgHeartrateFormatted: String? {
		guard let value = lapMessage?.averageHeartRate else {
			return nil
		}
		return formatter.formatUnitValue(measurement: value)
	}
	
	public var maxHeartrateFormatted: String? {
		guard let value = lapMessage?.maximumHeartRate else {
			return nil
		}
		return formatter.formatUnitValue(measurement: value)
	}
	
	public init(formatter: AGFormatter = AGFormatter.sharedFormatter, lapMessage: LapMessage? = nil) {
		self.formatter = formatter
		self.lapMessage = lapMessage
	}
	
}
