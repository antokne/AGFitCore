//
//  WFRecordMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 27/01/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol
import FitnessUnits

extension RecordMessage: FitMessageSpecificAdditions {
	
	public var messageName: String {
		if self as? PausedMessage != nil {
			return "Paused Record"
		}
		return "Record"
	}
	
	public var nameValues: [NameValueUnitType] {

		var result: [NameValueUnitType] = []
		
		if let timestamp = timeStamp?.recordDate?.timeIntervalSince1970 {
			result.append(NameValueUnitType(name: "timestamp", value: "\(Int(timestamp))", unit: "s"))
		}
		if let lat = position?.latitude?.converted(to: .degrees).value{
			result.append(NameValueUnitType(name: "lat", value: String(format: "%.4f", lat), unit: "º"))
		}
		if let lon = position?.longitude?.converted(to: .degrees).value {
			result.append(NameValueUnitType(name: "lon", value: String(format: "%.4f", lon), unit: "º"))
		}
		if let distMeasurement = distance {
			result.append(NameValueUnitType(name: "dist", value: formatter.formatUnitValue(measurement: distMeasurement, usingProvidedUnit: false, withDecimalPoints: 0)))
		}
		if let altitudeMeasurement = altitude {
			result.append(NameValueUnitType(name: "Alt", value: formatter.formatUnitValue(measurement: altitudeMeasurement, usingProvidedUnit: false, withDecimalPoints: 0)))
		}
		if let speedMeasurement = speed {
			result.append(NameValueUnitType(name: "Spd", value: formatter.formatUnitValue(measurement: speedMeasurement, usingProvidedUnit: false, withDecimalPoints: 1)))
		}
		if let powerMeasurement = power {
			result.append(NameValueUnitType(name: "Pwr", value: formatter.formatUnitValue(measurement: powerMeasurement, usingProvidedUnit: false, withDecimalPoints: 0)))
		}
		if let gradeMeasurement = grade {
			result.append(NameValueUnitType(name: "Grde", value: String(format: "%1.1f", gradeMeasurement.value), unit: gradeMeasurement.unit.symbol))
		}
		if let measurement = gpsAccuracy {
			result.append(NameValueUnitType(name: "gpsAcc", value: formatter.formatUnitValue(measurement: measurement)))
		}
		if let measurement = verticalSpeed {
			result.append(NameValueUnitType(name: "VSpd", value: formatter.formatUnitValue(measurement: measurement)))
		}
		if let measurement = heartRate {
			result.append(NameValueUnitType(name: "HR", value: formatter.formatUnitValue(measurement: measurement)))
		}
		if let measurement = cadence {
			result.append(NameValueUnitType(name: "Cad", value: formatter.formatUnitValue(measurement: measurement)))
		}
		if let measurement = temperature {
			result.append(NameValueUnitType(name: "Tmp", value: String(format:"%.0f", measurement.value), unit: measurement.unit.symbol))
		}
		if let percentContribution = leftRightBalance?.percentContribution {
			result.append(NameValueUnitType(name: "L/R Bal", value: String(percentContribution), unit: UnitPercent.percent.symbol))
		}
		if let activityType = activity?.rawValue {
			result.append(NameValueUnitType(name: "actType", value: String(activityType)))
		}
		if let measurement = torqueEffectiveness?.left {
			result.append(NameValueUnitType(name: "L/TE", value: formatter.formatUnitValue(measurement: measurement), unit: measurement.unit.symbol))
		}
		if let measurement = torqueEffectiveness?.right {
			result.append(NameValueUnitType(name: "R/TE", value: formatter.formatUnitValue(measurement: measurement), unit: measurement.unit.symbol))
		}
		if let measurement = pedalSmoothness?.combined {
			result.append(NameValueUnitType(name: "PdlSmth", value: String(format: "%.0f", measurement.value), unit: measurement.unit.symbol))
		}
		if let zone = zone {
			result.append(NameValueUnitType(name: "Zone", value: String(zone)))
		}
		
		return result
	}
}
