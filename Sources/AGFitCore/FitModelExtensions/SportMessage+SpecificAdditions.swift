//
//  SportMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 7/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol
import AntMessageProtocol

extension SportMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"Sport"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let name {
			result.append(NameValueUnitType(name: "name", value: name))
		}
		if let sport {
			result.append(NameValueUnitType(name: "sport", value: "\(sport.rawValue) \(sport.stringValue)"))
		}
		if let subSport {
			result.append(NameValueUnitType(name: "subSport", value: "\(subSport.rawValue) \(subSport.stringValue)"))
		}

		return result
	}
	
	public func specificMessageIsValid() -> Bool {
		true
	}

	public var specificInvalidReason: String {
		var message: String = ""
		
		return message
	}

}

extension SubSport {

	public var stringValue: String {
		switch self {
		case .generic:
			return "generic"
		case .treadmill:
			return "treadmill"
		case .street:
			return "street"
		case .trail:
			return "trail"
		case .track:
			return "track"
		case .spin:
			return "spin"
		case .indoorCycling:
			return "indoorCycling"
		case .road:
			return "road"
		case .mountain:
			return "mountain"
		case .downhill:
			return "downhill"
		case .recumbent:
			return "recumbent"
		case .cyclocross:
			return "cyclocross"
		case .handCycling:
			return "handCycling"
		case .trackCycling:
			return "trackCycling"
		case .indoorRowing:
			return "indoorRowing"
		case .elliptical:
			return "elliptical"
		case .stairClimbing:
			return "stairClimbing"
		case .lapSwimming:
			return "lapSwimming"
		case .openWater:
			return "openWater"
		case .flexibilityTraining:
			return "flexibilityTraining"
		case .strengthTraining:
			return "strengthTraining"
		case .warmUp:
			return "warmUp"
		case .match:
			return "match"
		case .exercise:
			return "exercise"
		case .challenge:
			return "challenge"
		case .indoorSkiing:
			return "indoorSkiing"
		case .cardioTraining:
			return "cardioTraining"
		case .indoorWalking:
			return "indoorWalking"
		case .eBikeFitness:
			return "eBikeFitness"
		case .bmx:
			return "bmx"
		case .casualWalking:
			return "casualWalking"
		case .speedWalking:
			return "speedWalking"
		case .bikeRunTransition:
			return "bikeRunTransition"
		case .runBikeTransition:
			return "runBikeTransition"
		case .swimBikeTransition:
			return "swimBikeTransition"
		case .atv:
			return "atv"
		case .motocross:
			return "motocross"
		case .backcountry:
			return "backcountry"
		case .resort:
			return "resort"
		case .rcDrone:
			return "rcDrone"
		case .wingsuit:
			return "wingsuit"
		case .whitewater:
			return "whitewater"
		case .skateSkiing:
			return "skateSkiing"
		case .yoga:
			return "yoga"
		case .pilates:
			return "pilates"
		case .indoorRunning:
			return "indoorRunning"
		case .gravelCycling:
			return "gravelCycling"
		case .eBikeMountain:
			return "eBikeMountain"
		case .commuting:
			return "commuting"
		case .mixedSurface:
			return "mixedSurface"
		case .navigate:
			return "navigate"
		case .trackMe:
			return "trackMe"
		case .map:
			return "map"
		case .singleGasDiving:
			return "singleGasDiving"
		case .multiGasDiving:
			return "multiGasDiving"
		case .gaugeDiving:
			return "gaugeDiving"
		case .apneaDiving:
			return "apneaDiving"
		case .apneaHHunting:
			return "apneaHHunting"
		case .virtualActivity:
			return "virtualActivity"
		case .obstacle:
			return "obstacle"
		case .all:
			return "all"
		case .invalid:
			return "invalid"
		}
	}
}
