//
//  DeveloperDataIdMessage+SpecificAdditions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 3/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import FitDataProtocol

extension DeveloperDataIdMessage: FitMessageSpecificAdditions {
	public var messageName: String {
		"DeveloperDataId"
	}
	
	public var nameValues: [NameValueUnitType] {
		var result: [NameValueUnitType] = []
		
		if let developerId {
			result.append(NameValueUnitType(name: "devId", value: developerId.base64EncodedString()))
		}
		if let applicationId {
			result.append(NameValueUnitType(name: "appId", value: applicationId.base64EncodedString()))
		}
		if let applicationVersion {
			result.append(NameValueUnitType(name: "appVer", value: String(applicationVersion)))
		}
		if let manufacturer {
			result.append(NameValueUnitType(name: "manufacturer", value: "\(manufacturer.manufacturerID):\(manufacturer.name)"))
		}
		if let dataIndex {
			result.append(NameValueUnitType(name: "dataIndex", value: "\(dataIndex)"))
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
