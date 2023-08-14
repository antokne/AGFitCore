//
//  FitMessage+Addtions.swift
//  FitViewer
//
//  Created by Antony Gardiner on 27/01/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import AGCore
import FitDataProtocol


public struct NameValueUnitType {
	var name: String
	var value: String
	var unit: String?
}

/// General extension for all FitMessage types only implemented by FitMessage
public protocol FitMessageGeneralAdditions {
	var name: String { get }
	var formatter: AGFormatter { get }
	var summary: String? { get }
	var summaryCount: Int? { get }
	var messageType: UInt16 { get }
	var devDataFields: String? { get }
	
	/// Checks if record is valid
	/// - Returns: returns true if record has valid data.
	func isValid() -> Bool
	var invalidReason: String { get }
}

/// Specific protocol implement by message types that we want to generate out for.
public protocol FitMessageSpecificAdditions {
	var messageName: String { get }
	var nameValues: [NameValueUnitType] { get }
	
	func specificMessageIsValid() -> Bool
	var specificInvalidReason: String { get }
}

private var internalSummaryKey: UInt8 = 0
private var internalSummaryCountKey: UInt8 = 0

extension FitMessage: FitMessageGeneralAdditions {
	
	public var formatter: AGFormatter {
		AGFormatter.sharedFormatter
	}

	public var name: String {
		
		if let message = self as? FitMessageSpecificAdditions {
			return message.messageName
		}
		
		return String(describing: self).replacingOccurrences(of: "FitDataProtocol.", with: "")
	}
	
	private var internalSummary: String? {
		get {
			return objc_getAssociatedObject(self, &internalSummaryKey) as? String
		}
		set {
			internalSummaryCount = newValue?.count
			objc_setAssociatedObject(self, &internalSummaryKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	private var internalSummaryCount: Int? {
		get {
			return objc_getAssociatedObject(self, &internalSummaryCountKey) as? Int
		}
		set {
			objc_setAssociatedObject(self, &internalSummaryCountKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	public var summaryCount: Int? {
		internalSummaryCount
	}
	
	public var summary: String? {
		
		if let internalSummary {
			return internalSummary
		}
		
		var s: String = ""
		if let message = self as? FitMessageSpecificAdditions {
			for (index, nameValue) in message.nameValues.enumerated() {
				if index > 0 {
					s += " "
				}
				s += "\(nameValue.name):\(nameValue.value)"
				if let unit = nameValue.unit {
					s += unit
				}
			}
		}
		else {
			s = "Sorry, not implemented yet."
		}
		
		internalSummary = s
		return s
	}
	
	public var namesCommaSeparated: String {
		var names = ""
		
		if let message = self as? FitMessageSpecificAdditions {
			for nameValue in message.nameValues {
				names += "\(nameValue.name),"
			}
		}
		return names
	}

	public var valuesCommaSeparated: String {
		var names = ""
		
		if let message = self as? FitMessageSpecificAdditions {
			for nameValue in message.nameValues {
				names += "\(nameValue.value),"
			}
		}
		return names
	}

	
	public var messageType: UInt16 {
		Self.globalMessageNumber()
	}
	
	public var devDataFields: String? {
		var s = ""
		for devValue in developerValues {
			if let name = devValue.fieldName, let value = devValue.value {
				s += "\(name):\(value)"
				if let units = devValue.units {
					s += units
				}
				s += " "
			}
		}
		return s
	}
	
	public func isValid() -> Bool {
		if let message = self as? FitMessageSpecificAdditions {
			return message.specificMessageIsValid()
		}
		return true // don't know so ignore for now.
	}
	
	public var invalidReason: String {
		if let message = self as? FitMessageSpecificAdditions {
			return message.specificInvalidReason
		}
		return ""
	}
	
}
