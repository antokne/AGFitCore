//
//  File.swift
//  
//
//  Created by Ant Gardiner on 8/08/23.
//

import Foundation
import MapKit
import FitDataProtocol
import AGCore

public class AGFitRadarPolygon: NSObject {
	
	private var recordMessages: [RecordMessage] = []

	public func addMessage(message: RecordMessage) {
		recordMessages.append(message)
	}
	
	var coodinates: [CLLocationCoordinate2D] {
		return recordMessages.compactMap { $0.location }
	}
		
	public var polyline: MKPolyline {
		let coords = coodinates
		return MKPolyline(coordinates: coords, count: coords.count)
	}
	
	public var maxCarCount: Int {
		let message = recordMessages.max { first, second in first.radarRangesNonZeroCount() < second.radarRangesNonZeroCount() }
		return message?.radarRangesNonZeroCount() ?? 0
	}
	
	func isPartof(recordMessage: RecordMessage) -> Bool {
		
		guard let lastMessage = recordMessages.last else {
			return false
		}
		
		guard let distance = lastMessage.distance(from: recordMessage) else {
			return false
		}
		
		if distance > 50 {
			return false
		}
		
		if lastMessage.radarRangesNonZeroCount() != recordMessage.radarRangesNonZeroCount() {
			return false
		}

		return true
	}

	public var strokeColor: AGColor {
		AGColor(red: 1.0, green: 0.1, blue: 0.1, alpha: 1)
	}
	
	public var lineWidth: Double {
		4 + Double(maxCarCount * 3)
	}

}


extension AGFitRadarPolygon: MKOverlay {
	
	public var coordinate: CLLocationCoordinate2D {
		polyline.coordinate
	}
	
	public var boundingMapRect: MKMapRect {
		polyline.boundingMapRect
	}
	
	
}

