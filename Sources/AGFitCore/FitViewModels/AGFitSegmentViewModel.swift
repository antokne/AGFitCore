//
//  AGFitSegmentViewModel.swift
//  
//
//  Created by Antony Gardiner on 15/03/23.
//

import Foundation

import Foundation
import AGCore
import FitDataProtocol

public class AGFitSegmentViewModel: NSObject, Identifiable {
	
	public enum AGSegmentType {
		case strava
		case wahooOnRoute
		case wahooOffRoute
		case unknown
		
		var title: String? {
			switch self {
			case .strava:
				return "Strava"
			case .wahooOnRoute:
				return "Wahoo On Route"
			case .wahooOffRoute:
				return "Wahoo Off Route"
			case .unknown:
				return nil
			}
		}
		
		static func typeFrom(string: String) -> AGSegmentType {
			switch string {
			case _ where string.starts(with: "STRAVA"):
				return .strava
			case _ where string.starts(with: "WAHOO_OFF"):
				return .wahooOffRoute
			case _ where string.starts(with: "WAHOO_ON"):
				return .wahooOnRoute
			default:
				return .unknown
			}
		}
	}
	
	private var formatter = AGFormatter.sharedFormatter
	
	private let segment: SegmentLapMessage
	
	public init(formatter: AGFormatter = AGFormatter.sharedFormatter, segment: SegmentLapMessage) {
		self.formatter = formatter
		self.segment = segment
	}
	
	public var startTimeFormatted: String {
		guard let date = segment.startTime?.recordDate else {
			return ""
		}
		return formatter.formatTime(date: date)

	}
	
	public var durationFormatted: String {
		if let value = segment.totalTimerTime?.value {
			return self.formatter.formatDuration(duration: value)
		}
		return ""
	}
	
	public var name: String {
		
		guard let name = segment.name else {
			return ""
		}
		
		switch type {
		case .strava:
			return name
		case .wahooOnRoute:
			return "Climb \(name)"
		case .wahooOffRoute:
			return "Climb \(name)"
		case .unknown:
			return name
		}
	}
	
	/// This should be unique accross all segments
	public var id: String {
		segment.uuid ?? UUID().uuidString
	}
	
	public var type: AGSegmentType {
		guard let uuid = segment.uuid else {
			return AGSegmentType.unknown
		}
		return AGSegmentType.typeFrom(string: uuid)
	}
	
	public var typeName: String {
		
		guard let uuid = segment.uuid else {
			return ""
		}
		
		guard let typeName = type.title else {
			return uuid
		}
		return typeName
	}
	
	public var url: URL? {
		
		guard let uuid = segment.uuid else {
			return nil
		}
		
		let parts = uuid.split(separator: "-")
		if parts.count == 2,
			let id = parts.last,
			typeName.starts(with: "Strava") {
			return URL(string: "https://www.strava.com/segments/\(id)")
		}
		return nil
	}
	
}
