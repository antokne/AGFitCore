//
//  AGRawFitViewModel.swift
//  FitViewer
//
//  Created by Ant Gardiner on 3/08/18.
//  Copyright © 2018 Antokne. All rights reserved.
//

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
	
	
	public func filterInvalidMessages() -> [FitMessage] {
		rawFitMessages.filter( { $0.isValid() })
	}
	
	lazy var recordMessages: [RecordMessage] = {
		rawFitMessages.compactMap {
			guard let recordMessage = $0 as? RecordMessage else {
				return nil
			}
			return recordMessage
		}
	}()
	
}


extension AGRawFitViewModel {
	
	public var radarAnnotations: [AGFitRadarAnnotation] {
		return recordMessages.compactMap {
			$0.hasRadarValues ? AGFitRadarAnnotation(recordMessage: $0) : nil
		}
	}
	
	public var radarPolygons: [AGFitRadarPolygon] {

		var overlays: [AGFitRadarPolygon] = []
		
		var current = AGFitRadarPolygon()
			
		for rawMessage in recordMessages {
			if rawMessage.hasRadarValues {
			
				if current.isPartof(recordMessage: rawMessage) {
					current.addMessage(message: rawMessage)
				}
				else {
					overlays.append(current)
					current = AGFitRadarPolygon()
					current.addMessage(message: rawMessage)
				}
			}
		}
		overlays.append(current)
		return overlays
	}
	
}
