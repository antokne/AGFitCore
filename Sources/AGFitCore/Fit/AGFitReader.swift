//
//  AGFitReader.swift
//  FitViewer
//
//  Created by Antony Gardiner on 6/09/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import Foundation
import os
import FitDataProtocol
import AGCore

public protocol AGFitReaderProtocol {
	func receivedMessage(message: FitMessage)
}

class AGFitReader {
	
	static var defaultMessages: [FitMessage.Type] {
		var messages = FitFileDecoder.defaultMessages
		messages.append(PausedMessage.self)
		return messages
	}
		
	private(set) public var url: URL
	
	private var messageDelegate: AGFitReaderProtocol?
	
	let log = Logger(subsystem: Bundle.mainBundleId ?? "AGFitReader", category: "AGFitReader")

	private(set) public var messages: [FitMessage] = []
	
	private var fitDecoder = FitFileDecoder(crcCheckingStrategy: .ignore)
	
	init(fileUrl: URL, messageDelegate: AGFitReaderProtocol? = nil) {
		self.url = fileUrl
		self.messageDelegate = messageDelegate
	}
	
	func readSummaryMessagesOnly() {
		read(messageTypes: [SessionMessage.self, LapMessage.self, DeviceInfoMessage.self])
	}

	/// Read  samples from url
	/// - Parameters:
	///   - url: url of file to load
	///   - sampleRate: number of samples to skip
	func read(messageTypes: [FitMessage.Type] = AGFitReader.defaultMessages) {
		
		log.debug("About to start read file")
		guard let fileData = try? Data(contentsOf: url) else {
			log.error("Failed to open file \(self.url)")
			return
		}
		
		log.debug("About to start decoding file")
		
		do {
			try fitDecoder.decode(data: fileData, messages: messageTypes) { [weak self] message in
				
				self?.messages.append(message)
				
				if let messageDelegate = self?.messageDelegate {
					messageDelegate.receivedMessage(message: message)
				}
			}
		}
		
		catch {
			log.debug("Failed to decode")
		}
		
		log.debug("decoding file finished")
	}
}
