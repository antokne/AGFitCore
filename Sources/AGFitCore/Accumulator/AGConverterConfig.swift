//
//  AGConverterConfig.swift
//  
//
//  Created by Antony Gardiner on 2/06/23.
//

import Foundation
import AGCore
import FitDataProtocol
import AntMessageProtocol

public struct AGDeveloperDataField {
	var name: String
	var fieldDefinitionNumber: UInt8
	var baseUnit: BaseType
	
	/// Optional native message num that this field is attached to
	var nativeMessageNum: UInt16?
}

public struct AGDeveloperData {
	var developerDataIndex: UInt8 = 0 // a sensible default
	var fields: [AGDeveloperDataField] = []
	
	public init(developerDataIndex: UInt8, fields: [AGDeveloperDataField]) {
		self.developerDataIndex = developerDataIndex
		self.fields = fields
	}
}

public struct AGConverterConfig {
	public var name: String?
	public var sport: Sport
	public var subSport: SubSport
	public var developerData: AGDeveloperData?
	
	public init(name: String? = nil,
				sport: Sport = .cycling,
				subSport: SubSport = .road,
				developerData: AGDeveloperData? = nil) {
		self.name = name
		self.sport = sport
		self.subSport = subSport
		self.developerData = developerData
	}
}

extension AGDeveloperData {
	
	static var RadarRangeFiledId: UInt8 = 0
	static var RadarSpeedFiledId: UInt8 = 1
	static var RadarCountFiledId: UInt8 = 2
	static var RadarCountSessionFiledId: UInt8 = 3
	static var RadarCountLapFiledId: UInt8 = 4
	static var RadarPassingSpeedFiledId: UInt8 = 5
	static var RadarPassingSpeedAbsFiledId: UInt8 = 6

	public static func generateDeveloperData(index: UInt8 = 0, from accumulatedData: AGAccumulator) -> AGDeveloperData? {
		
		var fields: [AGDeveloperDataField] = []
		
		if accumulatedData.rawData.arrayData.values.first(where: { $0.values(for: .radarRanges)?.isEmpty == false } ) != nil {
			// add record message developer data
			fields.append(AGDeveloperDataField(name: "radar_ranges",
											   fieldDefinitionNumber: RadarRangeFiledId,
											   baseUnit: .sint16,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}
		
		if accumulatedData.rawData.arrayData.values.first(where: { $0.values(for: .radarSpeeds)?.isEmpty == false } ) != nil {
			// add record message developer data
			fields.append(AGDeveloperDataField(name: "radar_speeds",
											   fieldDefinitionNumber: RadarSpeedFiledId,
											   baseUnit: .uint8,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}

		if accumulatedData.sessionData.currentData.value(for: .radarPassingSpeed, avgType: .last) != nil {
			// add record message developer data
			fields.append(AGDeveloperDataField(name: "passing_speed",
											   fieldDefinitionNumber: RadarPassingSpeedFiledId,
											   baseUnit: .uint8,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}
		
		if accumulatedData.sessionData.currentData.value(for: .radarPassingSpeedAbs, avgType: .last) != nil {
			// add record message developer data
			fields.append(AGDeveloperDataField(name: "passing_speedabs",
											   fieldDefinitionNumber: RadarPassingSpeedAbsFiledId,
											   baseUnit: .uint8,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}
		
		if accumulatedData.sessionData.currentData.value(for: .radarTargetTotalCount, avgType: .last) != nil {
			
			fields.append(AGDeveloperDataField(name: "radar_current",
											   fieldDefinitionNumber: RadarCountFiledId,
											   baseUnit: .uint16,
											   nativeMessageNum:
												RecordMessage.globalMessageNumber()))
			
			// add lap and session developer data
			fields.append(AGDeveloperDataField(name: "radar_total",
											   fieldDefinitionNumber: RadarCountSessionFiledId,
											   baseUnit: .uint16,
											   nativeMessageNum: SessionMessage.globalMessageNumber()))
			fields.append(AGDeveloperDataField(name: "radar_lap",
											   fieldDefinitionNumber: RadarCountLapFiledId,
											   baseUnit: .uint16,
											   nativeMessageNum: LapMessage.globalMessageNumber()))
		}
		
		if fields.count > 0 {
			return AGDeveloperData(developerDataIndex: index, fields: fields)
		}
		
		return nil
	}
	
}
