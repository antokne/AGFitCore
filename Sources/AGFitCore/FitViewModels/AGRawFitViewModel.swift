//
//  AGRawFitViewModel.swift
//  FitViewer
//
//  Created by Ant Gardiner on 3/08/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

import Cocoa
import os
import Foundation
import FitDataProtocol

public class AGRawFitViewModel: NSObject {

	public var rawFitMessages:[FitMessage] = []

	public func handleFitMessage(message: FitMessage) {
		rawFitMessages.append(message)
	}
	
	public func handleFitMessagesLoaded() {
		DispatchQueue.global(qos: .userInitiated).async {
			for message in self.rawFitMessages {
				DispatchQueue.main.async {
					_ = message.summary
				}
			}
		}
	}
}
