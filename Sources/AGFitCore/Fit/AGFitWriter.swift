//
//  AGFitWriter.swift
//  Gruppo
//
//  Created by Antony Gardiner on 17/05/23.
//

import Foundation
import FitDataProtocol

enum AGFitWriterError: Error {
	case NoFileIdMessage
	case FailedToWriteFile(error: Error)
}


/*
 Concept: accepts fit messages and periodically writes to a fit file.
 
 */

public class AGFitWriter {

	/// file location to write to
	private var fileURL: URL
	
	private var messages: [FitMessage] = []
	
	init(fileURL: URL) {
		self.fileURL = fileURL
	}
	
	func appendMessage(message: FitMessage) {
		// appends to the list of messages to write to a file
		messages.append(message)
	}

	func appendMessages(message: [FitMessage]) {
		// appends to the list of messages to write to a file
		messages.append(contentsOf: messages)
	}
	
	private func write() -> AGFitWriterError? {
		
		let encoder = FitFileEncoder(dataValidityStrategy: .none)
		
		var writeMessages: [FitMessage] = []
		
		var fileIdIdMessage: FileIdMessage? = nil
		for message in messages {
			
			switch message {
			case let fielIdMsg as FileIdMessage:
				fileIdIdMessage = fielIdMsg
			case let lapMsg as LapMessage:
				if lapMsg.timeStamp?.recordDate != nil {
					print("appending LAP message \(message)")
					writeMessages.append(message)
				}
				else {
					print("Got a nil lap message time stamp!!!")
				}
				
			default:
				print("appending message \(message)")
				writeMessages.append(message)
				break;
			}
		}
		
		guard let fileIdIdMessage else {
			return AGFitWriterError.NoFileIdMessage
		}
		
		let result = encoder.encode(fildIdMessage: fileIdIdMessage, messages: writeMessages)
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
