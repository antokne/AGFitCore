//
//  DeviceInfoMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 3/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol
import AntMessageProtocol

extension DeviceInfoMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"DeviceInfo"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let timestamp = timeStamp?.recordDate?.timeIntervalSince1970 {
			result.append(NameValueUnitType(name: "timestamp", value: "\(Int(timestamp))", unit: "s"))
		}
		if let serialNumber {
			result.append(NameValueUnitType(name: "SerialNo", value: String(serialNumber)))
		}
		if let cumulativeOpTime {
			result.append(NameValueUnitType(name: "OperatingTime", value: formatter.formatUnitValue(measurement: cumulativeOpTime)))
		}
		if let product {
			result.append(NameValueUnitType(name: "product", value: String(product)))
		}
		if let productName {
			result.append(NameValueUnitType(name: "productName", value: String(productName)))
		}
		if let manufacturer {
			result.append(NameValueUnitType(name: "manufacturer", value: "\(manufacturer.manufacturerID):\(manufacturer.name)"))
		}
		if let softwareVersion {
			result.append(NameValueUnitType(name: "sw ver", value: String(softwareVersion)))
		}
		if let batteryStatus = batteryStatus?.stringValue {
			result.append(NameValueUnitType(name: "bat", value: batteryStatus))
		}
		if let batteryVoltage {
			result.append(NameValueUnitType(name: "batV", value: formatter.formatUnitValue(measurement: batteryVoltage)))
		}
		if let deviceNumber {
			result.append(NameValueUnitType(name: "AntdeviceNum", value: String(deviceNumber)))
		}
		if let deviceIndex {
			result.append(NameValueUnitType(name: "deviceIndex", value: String(deviceIndex.index)))
		}
		if let deviceType {
			result.append(NameValueUnitType(name: "deviceType", value: String(deviceType.stringValue)))
		}
		if let hardwareVersion {
			result.append(NameValueUnitType(name: "hwVer", value: String(hardwareVersion)))
		}
		if let bodylocation {
			result.append(NameValueUnitType(name: "location", value: String(bodylocation.rawValue)))
		}
		if let sensorDescription {
			result.append(NameValueUnitType(name: "descr", value: String(sensorDescription)))
		}
		if let transmissionType {
			result.append(NameValueUnitType(name: "transmissionType", value: String(transmissionType.rawValue)))
		}
		if let antNetwork {
			result.append(NameValueUnitType(name: "antNetwork", value: String(antNetwork.rawValue)))
		}
		if let source {
			result.append(NameValueUnitType(name: "source", value: source.stringValue))
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

extension DeviceInfoMessage {
	public var batteryPercent: Int? {
		for devValue in developerValues {
			if let name = devValue.fieldName, let value = devValue.value as? Double {
				if name == "charge" {
					return Int(value)
				}
			}
		}
		return nil
	}
	
}


extension DeviceType {
	var stringValue: String {
		switch self {
			
		case .unknown:
			return "Unknown"
		case .sync:
			return "Sync"
		case .bikePower:
			return "Power"
		case .multiSportSpeedDistance:
			return "multisportSpeed/Dist"
		case .controls:
			return "Control"
		case .fitnessEquipment:
			return "FE"
		case .bloodPressure:
			return "BP"
		case .geoCache:
			return "GeoCache"
		case .lightElectricVehicle:
			return "LEV"
		case .activityMonitor:
			return "Monitor"
		case .environment:
			return "Env"
		case .racquet:
			return "Racquet"
		case .muscleOxygen:
			return "MO2"
		case .bikeShifting:
			return "Gears"
		case .bikeLights:
			return "Light"
		case .bikeLightsSecondary:
			return "Light"
		case .bikeRadar:
			return "Radar"
		case .tracker:
			return "Tracker"
		case .dropperSeatpost:
			return "Dropper Post"
		case .bikeSuspension:
			return "Suspension"
		case .weightScale:
			return "Scale"
		case .heartRate:
			return "HR"
		case .bikeSpeedCadence:
			return "Speed/Cadence"
		case .bikeCadence:
			return "Cadence"
		case .bikeSpeed:
			return "Speed"
		case .strideBasedSpeedDistance:
			return "Stride"
		}
	}
}
