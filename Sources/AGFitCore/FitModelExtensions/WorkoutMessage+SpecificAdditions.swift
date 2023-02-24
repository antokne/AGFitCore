//
//  WorkoutMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 7/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension WorkoutMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"Workout"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let workoutName {
			result.append(NameValueUnitType(name: "Name", value: workoutName))
		}
		if let sport {
			result.append(NameValueUnitType(name: "sport", value: "\(sport.rawValue) \(sport.stringValue)"))
		}
		if let subSport {
			result.append(NameValueUnitType(name: "subSport", value: "\(subSport.rawValue) \(subSport.stringValue)"))
		}
		if let poolLength, let poolLengthUnit {
			result.append(NameValueUnitType(name: "poolLen", value: formatter.formatUnitValue(measurement: poolLength), unit: poolLengthUnit.stringValue))
		}
		if let numberOfValidSteps {
			result.append(NameValueUnitType(name: "ValSteps", value: "\(numberOfValidSteps)"))
		}

		return result
	}
}

extension MeasurementDisplayType {
	public var stringValue: String {
		switch self {
		case .metric:
			return "metric"
		case .statute:
			return "statute"
		case .nautical:
			return "nautical"
		case .invalid:
			return "invalid"
		}
	}
}
