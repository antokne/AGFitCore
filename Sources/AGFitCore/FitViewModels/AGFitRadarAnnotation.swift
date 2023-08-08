//
//  AGFitRadarAnnotation.swift
//  
//
//  Created by Ant Gardiner on 28/07/23.
//

import Foundation
import MapKit
import FitDataProtocol
import AGCore

public class AGFitRadarAnnotation: NSObject {
	private var recordMessage: RecordMessage

	public init(recordMessage: RecordMessage) {
		self.recordMessage = recordMessage
	}
	
	let imageColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 1)
	
	public lazy var image: AGImage? = {
		AGImage(systemSymbolName: "car.circle", accessibilityDescription: "car.circle")?
			.tint(color: imageColor)
	}()
}


extension AGFitRadarAnnotation : MKAnnotation {
	
	public var coordinate: CLLocationCoordinate2D {
		if let lat = recordMessage.position?.latitude?.converted(to: .degrees).value,
		   let lng = recordMessage.position?.longitude?.converted(to: .degrees).value {
			return CLLocationCoordinate2D(latitude: lat, longitude: lng)
		}
		return CLLocationCoordinate2D()
	}
	
	
	
}



extension AGImage {
	func tint(color: AGColor) -> AGImage {
#if os(macOS)

		return AGImage(size: size, flipped: false) { rect -> Bool in
			color.set()
			rect.fill()
			self.draw(in: rect, from: AGRect(origin: .zero, size: self.size), operation: .destinationIn, fraction: 1.0)
			return true
		}
#endif
#if os(iOS)
		return self.withTintColor(color, renderingMode: .alwaysTemplate)
#endif

	}
}
