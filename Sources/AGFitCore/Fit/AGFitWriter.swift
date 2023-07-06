//
//  AGFitWriter.swift
//  Gruppo
//
//  Created by Antony Gardiner on 17/05/23.
//

import Foundation
import os
import FitDataProtocol

public enum AGFitWriterError: Error {
	case NoFileIdMessage
	case FailedToWriteFile(error: Error)
}


/*
  Accecpts fit messages and then writes to file in one go when requested.
 
 */

public class AGFitWriter {

	/// file location to write to
	private var fileURL: URL
	
	private(set) public var messages: [FitMessage] = []
	
	private(set) public var developerDataIDs: [DeveloperDataIdMessage] = []
	private(set) public var fieldDescriptions: [FieldDescriptionMessage] = []
	
	let logger = Logger(subsystem: "com.antokne.fitcore", category: "AGFitWriter")

	public init(fileURL: URL) {
		self.fileURL = fileURL
	}

	func appendDeveloperDataId(developerDataID: DeveloperDataIdMessage) {
		developerDataIDs.append(developerDataID)
	}
	
	func appendFieldDescription(fieldDescription: FieldDescriptionMessage) {
		fieldDescriptions.append(fieldDescription)
	}
	
	func appendMessage(message: FitMessage) {
		// appends to the list of messages to write to a file
		
		guard message as? DeveloperDataIdMessage == nil else {
			assert(false, "Use add appendDeveloperDataId method")
			return
		}
		guard message as? DeveloperDataIdMessage == nil else {
			assert(false, "Use add appendFieldDescription method")
			return
		}

		
		messages.append(message)
	}

	func appendMessages(messages: [FitMessage]) {
		// appends to the list of messages to write to a file
		self.messages.append(contentsOf: messages)
	}
	
	public func write() -> AGFitWriterError? {
		
		logger.info("Start write")
		let encoder = FitFileEncoder(dataValidityStrategy: .none)
		
		var writeMessages: [FitMessage] = []
		
		var fileIdIdMessage: FileIdMessage? = nil
		for message in messages {
			
			switch message {
			case let fielIdMsg as FileIdMessage:
				fileIdIdMessage = fielIdMsg
			case let lapMsg as LapMessage:
				if lapMsg.timeStamp?.recordDate != nil {
					writeMessages.append(message)
				}
				else {
					logger.warning("Got a nil lap message time stamp!!!")
				}
				
			default:
				writeMessages.append(message)
				break;
			}
		}
		
		guard let fileIdIdMessage else {
			return AGFitWriterError.NoFileIdMessage
		}
		
		let result = encoder.encode(fileIdMessage: fileIdIdMessage,
									messages: writeMessages,
									developerDataIDs: developerDataIDs,
									fieldDescriptions: fieldDescriptions)
		switch result {
		case .success(let data):
			do {
				try data.write(to: fileURL)
			}
			catch {
				logger.fault("failed to save to file \(error, privacy: .public)")
			}
		case .failure(let error):
			logger.fault("dam encoding failed \(error, privacy: .public)")
			return AGFitWriterError.FailedToWriteFile(error: error)
		}
		
		logger.info("write completed")

		return nil
		
	}
	
	
}
