//
//  AGFitConfig.swift
//  FitViewer
//
//  Created by Ant Gardiner on 1/08/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import Foundation
import FitDataProtocol

public class AGFitConfigViewModel: NSObject {

	/// the ftp that was used during the workout
	// public var ftp: NSNumber = NSNumber(floatLiteral: 0)
	
	/// Dictionary of devices keyed on Device Index
	public var devices: [UInt8: AGFitDeviceViewModel] = [: ]
	
	public func addDeviceInfoMessage(deviceInfoMessage: DeviceInfoMessage) {
		
		if let deviceIndex = deviceInfoMessage.deviceIndex?.index {
			var device = devices[deviceIndex]
			if device == nil {
				device = AGFitDeviceViewModel()
				devices[deviceIndex] = device
			}
			
			if let device {
				device.addDeviceInfoMessage(deviceInfoMessage: deviceInfoMessage)
			}
		}
	}
}
