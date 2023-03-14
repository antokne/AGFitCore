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

enum FitMessageType: UInt16 {
	case fileId = 0			// = FIT_MESG_NUM_FILE_ID
	case deviceSettings		// = FIT_MESG_NUM_DEVICE_SETTINGS
	case userProfile		// = FIT_MESG_NUM_USER_PROFILE
	case hRMProfile			// = FIT_MESG_NUM_HRM_PROFILE
	case bikeProfile		// = FIT_MESG_NUM_BIKE_PROFILE
	case zonesTarget		// = FIT_MESG_NUM_ZONES_TARGET
	case hRZone				// = FIT_MESG_NUM_HR_ZONE
	case powerZone			// = FIT_MESG_NUM_POWER_ZONE
	case sport				// = FIT_MESG_NUM_SPORT
	case goal				// = FIT_MESG_NUM_GOAL
	case session			// = FIT_MESG_NUM_SESSION
	case lap				// = FIT_MESG_NUM_LAP
	case record = 20		// = FIT_MESG_NUM_RECORD
	case event				// = FIT_MESG_NUM_EVENT
	case deviceInfo			// = FIT_MESG_NUM_DEVICE_INFO
	case workout			// = FIT_MESG_NUM_WORKOUT
	case course				// = FIT_MESG_NUM_COURSE
	case coursePoint		// = FIT_MESG_NUM_COURSE_POINT
	case totals				// = FIT_MESG_NUM_TOTALS
	case activity			// = FIT_MESG_NUM_ACTIVITY
	case length				// = FIT_MESG_NUM_LENGTH
	case segmentLap			// = FIT_MESG_NUM_SEGMENT_LAP
	case segmentId			// = FIT_MESG_NUM_SEGMENT_ID
	case segmentLeaderboardEntry// = FIT_MESG_NUM_SEGMENT_LEADERBOARD_ENTRY
	case fieldDescription	// = FIT_MESG_NUM_FIELD_DESCRIPTION
	case developerDataId	// = FIT_MESG_NUM_DEVELOPER_DATA_ID
	
	// Wahoo Custom messages
	case wahooPausedRecord// = FIT_MESG_NUM_WAHOO_PAUSED_RECORD
	case wahooMesgId// = FIT_MESG_NUM_WAHOO_MESG_ID
	case wahooSegmentLeaderboardEntry// = FIT_MESG_NUM_WAHOO_SEGMENT_LEADERBOARD_ENTRY
	
	// ANT
	case antRx// = FIT_MESG_NUM_ANT_RX
	
	// HR Data
	case heartRateVariability// = FIT_MESG_NUM_HRV
}

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
}

/// Specific protocol implement by message types that we want to generate out for.
public protocol FitMessageSpecificAdditions {
	var messageName: String { get }
	var nameValues: [NameValueUnitType] { get }
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
}
