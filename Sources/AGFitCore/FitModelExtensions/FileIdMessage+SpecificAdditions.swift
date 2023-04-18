//
//  WFFieldId+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 3/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol


extension FileIdMessage: FitMessageSpecificAdditions {
	
	public var messageName: String {
		"FileId"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let timestamp = fileCreationDate?.recordDate?.timeIntervalSince1970 {
			result.append(NameValueUnitType(name: "CreateTime", value: String(timestamp)))
		}
		if let serialNo = deviceSerialNumber {
			result.append(NameValueUnitType(name: "SerialNo", value: "\(Int(serialNo))"))
		}
		if let productName {
			result.append(NameValueUnitType(name: "productName", value: productName))
		}
		if let product {
			result.append(NameValueUnitType(name: "productName", value: String(product)))
		}
		if let manufacturer = manufacturer {
			result.append(NameValueUnitType(name: "manufacturer", value: "\(Int(manufacturer.manufacturerID)) \(manufacturer.name)"))
		}
		if let fileNumber {
			result.append(NameValueUnitType(name: "fileNumber", value: String(fileNumber)))
		}
		if let fileType = fileType?.rawValue {
			result.append(NameValueUnitType(name: "fileType", value: String(fileType)))
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
