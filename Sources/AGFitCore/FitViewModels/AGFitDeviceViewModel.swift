//
//  AGFitDevice.swift
//  FitViewer
//
//  Created by Antony Gardiner on 20/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

public class AGFitDeviceViewModel: NSObject {

	
	public var manufacturer: String? {
		deviceInfoMessages.last?.manufacturer?.name
	}
	
	public var productName: String? {
		deviceInfoMessages.last?.productName
	}
	
	public var batteryState: String? {
		if let batPercent = deviceInfoMessages.last?.batteryPercent {
			return String(format: "%d%%", batPercent)
		}
		if let batStatus = deviceInfoMessages.last?.batteryStatus?.stringValue {
			return batStatus
		}
		return nil
	}

	public var deviceIndex: UInt8? {
		deviceInfoMessages.last?.deviceIndex?.index
	}
	
	public var batteryUsage: String?
	public var batteryEstimate: String?

	private var deviceInfoMessages: [DeviceInfoMessage] = []
	
	func addDeviceInfoMessage(deviceInfoMessage: DeviceInfoMessage) {
		deviceInfoMessages.append(deviceInfoMessage)
		calculateBatteryUsage()
	}
	
	public func calculateBatteryUsage() {
		
		let elemntDevices = deviceInfoMessages
		
		// Get the first and last device info message records for the ELEMNT that have a battery %
		let first = elemntDevices.first { $0.batteryPercent != nil }
		let last = elemntDevices.last { $0.batteryPercent != nil }
		
		/*
		 *  Calc is:
		 * 	percent used per hour = Percent change (first - last) / duration (last - first)
		 *  Estimated battery life = 100 / percent used per hour
		 */
		
		let totalTimeS = Int(last?.timeStamp?.recordDate?.timeIntervalSince1970 ?? 0) - Int(first?.timeStamp?.recordDate?.timeIntervalSince1970 ?? 0)
		let timeHours = Double(totalTimeS) / 60 / 60
		
		let percentChange = Int(first?.batteryPercent ?? 0) - Int(last?.batteryPercent ?? 0)
		
		
		if percentChange > 0 && timeHours > 0 {
			let percentPerHour = Double(percentChange) / Double(timeHours)
			batteryUsage = String(format: "%.2f", percentPerHour) + "%/hr"
			batteryEstimate = String(format: "%.2f", 100.0 / percentPerHour) + "hrs"
		}
	}
}
