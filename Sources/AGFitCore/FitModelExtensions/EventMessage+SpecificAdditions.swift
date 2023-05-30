//
//  EventMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 3/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension EventMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"Event"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let timestamp = timeStamp?.recordDate?.timeIntervalSince1970 {
			result.append(NameValueUnitType(name: "timestamp", value: "\(Int(timestamp))", unit: "s"))
		}
		if let event {
			result.append(NameValueUnitType(name: "event", value: event.name))
		}
		if let eventType {
			result.append(NameValueUnitType(name: "type", value: eventType.name))
		}
		if let eventGroup {
			result.append(NameValueUnitType(name: "group", value: String(eventGroup)))
		}
		if let frontGearNum {
			result.append(NameValueUnitType(name: "FGearNo", value: String(frontGearNum)))
		}
		if let frontGear {
			result.append(NameValueUnitType(name: "FGear", value: String(frontGear)))
		}
		if let rearGearNum {
			result.append(NameValueUnitType(name: "RGearNo", value: String(rearGearNum)))
		}
		if let rearGear {
			result.append(NameValueUnitType(name: "RGear", value: String(rearGear)))
		}
		
		return result
	}
	
	public func specificMessageIsValid() -> Bool {
		true
	}
	
	public var specificInvalidReason: String {
		let message: String = ""
		
		return message
	}

}

extension EventType {
	public var name: String {
		switch self {
		case .start:
			return "start"
		case .stop:
			return "stop"
		case .consecutiveDeprecated:
			return "consecutiveDeprecated"
		case .marker:
			return "marker"
		case .stopAll:
			return "stopAll"
		case .beginDeprecated:
			return "beginDeprecated"
		case .endDeprecated:
			return "endDeprecated"
		case .endAllDeprecated:
			return "endAllDeprecated"
		case .stopDisable:
			return "stopDisable"
		case .stopDisableAll:
			return "stopDisableAll"
		case .invalid:
			return "invalid"
		}
	}
}

extension Event {
	public var name: String {
		switch self {
		case .timer:
			return "Timer"
		case .workout:
			return "Workout"
		case .workoutStep:
			return "WorkoutStep"
		case .powerDown:
			return "PowerDown"
		case .powerUp:
			return "PowerUp"
		case .offCourse:
			return "Off course"
		case .session:
			return "Session"
		case .lap:
			return "Lap"
		case .coursePoint:
			return "CoursePoint"
		case .battery:
			return "Battery"
		case .virtualPatnerPace:
			return "virtualPatnerPace"
		case .hrHighAlert:
			return "hrHighAlert"
		case .hrLowAlert:
			return "hrLowAlert"
		case .speedHighAlert:
			return "speedHighAlert"
		case .speedLowAlert:
			return "speedLowAlert"
		case .cadenceHighAlert:
			return "cadenceHighAlert"
		case .cadenceLowAlert:
			return "cadenceLowAlert"
		case .powerHighAlert:
			return "powerHighAlert"
		case .powerLowAlert:
			return "powerLowAlert"
		case .recoveryHr:
			return "recoveryHr"
		case .batteryLow:
			return "batteryLow"
		case .timeDurationAlert:
			return "timeDurationAlert"
		case .distanceDurationAlert:
			return "distanceDurationAlert"
		case .calorieDurationAlert:
			return "calorieDurationAlert"
		case .activity:
			return "activity"
		case .fitnessEquipment:
			return "fitnessEquipment"
		case .length:
			return "length"
		case .userMarker:
			return "userMarker"
		case .sportPoint:
			return "sportPoint"
		case .calibration:
			return "calibration"
		case .frontGearChange:
			return "frontGearChange"
		case .rearGearChange:
			return "rearGearChange"
		case .riderPositionChange:
			return "riderPositionChange"
		case .elevationHighAlert:
			return "elevationHighAlert"
		case .elevationLowAlert:
			return "elevationLowAlert"
		case .communicationTimeout:
			return "communicationTimeout"
		case .invalid:
			return "invalid"
		}
	}
}
