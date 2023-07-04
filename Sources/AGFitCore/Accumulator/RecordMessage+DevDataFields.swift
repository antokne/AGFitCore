//
//  RecordMessage+DevDataFields.swift
//  
//
//  Created by Ant Gardiner on 4/07/23.
//

import Foundation
import FitDataProtocol
import AGCore

extension RecordMessage {
        
    var radarDisconnectedRanges: [Int16] {
        [255, 255, 255, 255, 255, 255, 255, 255]
    }

    var radarNoRanges: [Int16] {
        [0, 0, 0, 0, 0, 0, 0, 0]
    }
    
    var radarDisconnectedSpeeds: [UInt8] {
        [255, 255, 255, 255, 255, 255, 255, 255]
    }

    var radarNoSpeeds: [UInt8] {
        [0, 0, 0, 0, 0, 0, 0, 0]
    }
    
    func encodeDevDataFields(fieldDescriptionMessages: [FieldDescriptionMessage],
                             rawData: AGAccumulatorRawInstantData,
                             arrayData: AGAccumulatorRawArrayInstantData?) {
        
        // just check developer fields for this message
        let fields = fieldDescriptionMessages.fields(for: RecordMessage.globalMessageNumber())
        for field in fields {
            
            var value: Any? = nil
            
            switch field.definitionNumber {
            case AGDeveloperData.RadarRangeFiledId:
                if let doubles: [Double] = arrayData?.values(for: .radarRanges) {
                    var tempValue: [Int16] = doubles.map { Int16($0) } // convert to array of correct units and UInt16 as stored.
                    while tempValue.count < 8 { tempValue.append(Int16(0)) }
                    value = tempValue
                }
                else if let radarStatus = rawData.value(for: .radarStatus), radarStatus == 0 {
                    value = radarDisconnectedRanges
                }
                else {
                    value = radarNoRanges
                }
            case AGDeveloperData.RadarSpeedFiledId:
                if let doubles: [Double] = arrayData?.values(for: .radarSpeeds) {
                    var tempValue: [UInt8] = doubles.map { UInt8($0) } // convert to array of correct units and UInt8 as stored.
                    while tempValue.count < 8 { tempValue.append(UInt8(0)) }
                    value = tempValue
                }
                else if let radarStatus = rawData.value(for: .radarStatus), radarStatus == 0 {
                    value = radarDisconnectedSpeeds
                }
                else {
                    value = radarNoSpeeds
                }
            case AGDeveloperData.RadarCountFiledId:
                if let doubleValue = rawData.value(for: .radarTargetTotalCount) {
                    value = UInt16(doubleValue)
                }
            case AGDeveloperData.RadarPassingSpeedFiledId:
                if let doubleValue = rawData.value(for: .radarPassingSpeed) {
                    value = UInt8(doubleValue)
                }
            case AGDeveloperData.RadarPassingSpeedAbsFiledId:
                if let doubleValue = rawData.value(for: .radarPassingSpeedAbs) {
                    value = UInt8(doubleValue)
                }
                    
            default:
                break
            }
            
            if let value {
                self.addDeveloperData(value: value, fieldDescription: field)
            }
        }
    
    }
        
}
