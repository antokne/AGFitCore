//
//  AGFitWriter.swift
//  Gruppo
//
//  Created by Antony Gardiner on 17/05/23.
//

import Foundation
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
					print("Got a nil lap message time stamp!!!")
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
				print("failed to save to file \(error)")
			}
		case .failure(let error):
			print("dam failed \(error)")
			return AGFitWriterError.FailedToWriteFile(error: error)
		}
		
		return nil
		
	}
	
	
}
