//
//  File.swift
//  
//
//  Created by Ant Gardiner on 8/08/23.
//

import Foundation
import AntMessageProtocol
import FitDataProtocol
import AGFitCore

extension RecordMessage {
	
	static func fieldDesciptionMessages() -> [FieldDescriptionMessage] {
		
		let radarRangesField = FieldDescriptionMessage(dataIndex: 0,
													   definitionNumber: AGFitDeveloperData.RadarRangeFieldId,
													   fieldName: "radar_ranges",
													   baseInfo: BaseTypeData(type: .sint16),
													   units: nil,
													   baseUnits: nil,
													   messageNumber: 20,
													   fieldNumber: nil)
		
		let radarSpeedsField = FieldDescriptionMessage(dataIndex: 0,
													   definitionNumber: AGFitDeveloperData.RadarSpeedFieldId,
													   fieldName: "radar_speeds",
													   baseInfo: BaseTypeData(type: .uint8),
													   units: nil,
													   baseUnits: nil,
													   messageNumber: 20,
													   fieldNumber: nil)
		
		let radarCurrentField = FieldDescriptionMessage(dataIndex: 0,
														definitionNumber: AGFitDeveloperData.RadarCountFieldId,
														fieldName: "radar_current",
														baseInfo: BaseTypeData(type: .uint16),
														units: nil,
														baseUnits: nil,
														messageNumber: 20,
														fieldNumber: nil)
		
		let passingSpeedField = FieldDescriptionMessage(dataIndex: 0,
														definitionNumber: AGFitDeveloperData.RadarPassingSpeedFieldId,
														fieldName: "passing_speed",
														baseInfo: BaseTypeData(type: .uint8),
														units: nil,
														baseUnits: nil,
														messageNumber: 20,
														fieldNumber: nil)
		
		let passingSpeedAbsField = FieldDescriptionMessage(dataIndex: 0,
														   definitionNumber: AGFitDeveloperData.RadarPassingSpeedAbsFieldId,
														   fieldName: "passing_speedabs",
														   baseInfo: BaseTypeData(type: .uint8),
														   units: nil,
														   baseUnits: nil,
														   messageNumber: 20,
														   fieldNumber: nil)
		
		return [radarRangesField, radarSpeedsField, radarCurrentField, passingSpeedField, passingSpeedAbsField]
		
	}
	
	/// Passes the record message through and encode/decode process to ensure all develoepr data fields are correctly generated.
	/// - Parameter message: the record message to encode/decode
	/// - Returns: non nil if succeeds.
	static func encodeDecode(message: RecordMessage) -> RecordMessage? {
		
		let encoder = FitFileEncoder(dataValidityStrategy: .none)

		let developerDataId = DeveloperDataIdMessage(dataIndex: 0)

		let fileIdMesage = FileIdMessage(deviceSerialNumber: 34353535,
										 fileCreationDate: FitTime(date: .gmt),
										 manufacturer: Manufacturer.unknown,
										 fileType: FileType.activity,
										 productName: "Bob")
		
		let result = encoder.encode(fileIdMessage: fileIdMesage,
									messages: [message],
									developerDataIDs: [developerDataId],
									fieldDescriptions: fieldDesciptionMessages())

		var dataEndcoded: Data? = nil
		switch result {
		case .success(let data):
			dataEndcoded = data
		case .failure(_):
			return nil
		}
		
		guard let dataEndcoded else {
			return nil
		}
		
		var fitDecoder = FitFileDecoder(crcCheckingStrategy: .ignore)
		var decodedRecordMessage: RecordMessage?
		do {
			try fitDecoder.decode(data: dataEndcoded, messages: FitFileDecoder.defaultMessages) { message in
				decodedRecordMessage = message as? RecordMessage
				return
			}
		}
		
		catch {
			return nil
		}
		return decodedRecordMessage
	}
	
}
