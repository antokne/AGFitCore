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

/// Represents a dev developer data field
public struct AGFitDeveloperDataField {
    
    /// The name of the field
	var name: String
    
    /// The fields definition number
	var fieldDefinitionNumber: UInt8
    
    /// The units of the field.
	var baseUnit: BaseType
	
	/// Optional native message num that this field is attached to
	var nativeMessageNum: UInt16?
}

public struct AGFitDeveloperData {
    
    /// Index for developer of these data fields. probably should not be 0.
	var developerDataIndex: UInt8 = 0 // a sensible default
    
    /// array of developer data fields to encode
	var fields: [AGFitDeveloperDataField] = []
	
	public init(developerDataIndex: UInt8, fields: [AGFitDeveloperDataField]) {
		self.developerDataIndex = developerDataIndex
		self.fields = fields
	}
}

public struct AGFitConverterConfig {
	public var name: String?
	public var sport: Sport
	public var subSport: SubSport
	public var developerData: AGFitDeveloperData?
	var metric: Bool

	public init(name: String? = nil,
				sport: Sport = .cycling,
				subSport: SubSport = .road,
				developerData: AGFitDeveloperData? = nil,
				metric: Bool) {
		self.name = name
		self.sport = sport
		self.subSport = subSport
		self.developerData = developerData
		self.metric = metric
	}
}

extension AGFitDeveloperData {
	
    /// Field id for radar ranges
	static var RadarRangeFieldId: UInt8 = 0
    
    /// Field id
    static var RadarSpeedFieldId: UInt8 = 1

    /// Field id current radar count
	static var RadarCountFieldId: UInt8 = 2

    /// Field id for count in a session
	static var RadarCountSessionFieldId: UInt8 = 3

    /// Field id for count in current lap
	static var RadarCountLapFieldId: UInt8 = 4

    /// Field id for radar passing speed relative to rider
	static var RadarPassingSpeedFieldId: UInt8 = 5

    /// Field id for radar passing speed absolute
	static var RadarPassingSpeedAbsFieldId: UInt8 = 6
    
    /// Generates a list of developer data fields to encode into messages for the MyBikeTraffic website.
    /// see https://github.com/kartoone/mybiketraffic/blob/master/source/MyBikeTrafficFitContributions.mc
    /// - Parameters:
    ///   - index: developer index
    ///   - accumulatedData: checks accumulated data and only adds developer data fields for data that exists.
    /// - Returns: the configured developer data.
	public static func generateMyBikeTafficDeveloperData(index: UInt8 = 0, from accumulatedData: AGAccumulator) -> AGFitDeveloperData? {
		
		var fields: [AGFitDeveloperDataField] = []
		
		if accumulatedData.rawData.arrayData.values.first(where: { $0.values(for: .radarRanges)?.isEmpty == false } ) != nil {
			// add record message developer data
			fields.append(AGFitDeveloperDataField(name: "radar_ranges",
											   fieldDefinitionNumber: RadarRangeFieldId,
											   baseUnit: .sint16,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}
		
		if accumulatedData.rawData.arrayData.values.first(where: { $0.values(for: .radarSpeeds)?.isEmpty == false } ) != nil {
			// add record message developer data
			fields.append(AGFitDeveloperDataField(name: "radar_speeds",
											   fieldDefinitionNumber: RadarSpeedFieldId,
											   baseUnit: .uint8,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}

		if accumulatedData.sessionData.currentData.value(for: .radarPassingSpeed, avgType: .last) != nil {
			// add record message developer data
			fields.append(AGFitDeveloperDataField(name: "passing_speed",
											   fieldDefinitionNumber: RadarPassingSpeedFieldId,
											   baseUnit: .uint8,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}
		
		if accumulatedData.sessionData.currentData.value(for: .radarPassingSpeedAbs, avgType: .last) != nil {
			// add record message developer data
			fields.append(AGFitDeveloperDataField(name: "passing_speedabs",
											   fieldDefinitionNumber: RadarPassingSpeedAbsFieldId,
											   baseUnit: .uint8,
											   nativeMessageNum: RecordMessage.globalMessageNumber()))
		}
		
		if accumulatedData.sessionData.currentData.value(for: .radarTargetTotalCount, avgType: .last) != nil {
			
			fields.append(AGFitDeveloperDataField(name: "radar_current",
											   fieldDefinitionNumber: RadarCountFieldId,
											   baseUnit: .uint16,
											   nativeMessageNum:
												RecordMessage.globalMessageNumber()))
			
			// add lap and session developer data
			fields.append(AGFitDeveloperDataField(name: "radar_total",
											   fieldDefinitionNumber: RadarCountSessionFieldId,
											   baseUnit: .uint16,
											   nativeMessageNum: SessionMessage.globalMessageNumber()))
			fields.append(AGFitDeveloperDataField(name: "radar_lap",
											   fieldDefinitionNumber: RadarCountLapFieldId,
											   baseUnit: .uint16,
											   nativeMessageNum: LapMessage.globalMessageNumber()))
		}
		
		if fields.count > 0 {
			return AGFitDeveloperData(developerDataIndex: index, fields: fields)
		}
		
		return nil
	}
	
}
