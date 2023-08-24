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
		AGImage(systemSymbolName: "car", accessibilityDescription: "car.circle")?
			.tint(color: imageColor)
	}()
	
	var radarTitle: String {
		recordMessage.radarTitle()
	}
	var radarDescription: String? {
		recordMessage.radarDescription()
	}
}


extension AGFitRadarAnnotation : MKAnnotation {
	
	@objc dynamic public var coordinate: CLLocationCoordinate2D {
		if let lat = recordMessage.position?.latitude?.converted(to: .degrees).value,
		   let lng = recordMessage.position?.longitude?.converted(to: .degrees).value {
			return CLLocationCoordinate2D(latitude: lat, longitude: lng)
		}
		return CLLocationCoordinate2D()
	}
	
	public var title: String? {
		"Vehicles"
	}
	
	public var subtitle: String? {
		[recordMessage.radarTitle(), recordMessage.radarDescription()]
			.compactMap { $0 }
			.joined()
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


public class AGFitRadarCluster: MKAnnotationView {
	
	public override func prepareForDisplay() {
		super.prepareForDisplay()
		
		guard let cluster = annotation as? MKClusterAnnotation else {
			return
		}
		
		let totalRadarPoints = cluster.memberAnnotations.count
		if totalRadarPoints > 1 {
			image = NSImage(systemSymbolName: "car.2", accessibilityDescription: nil)
		}
		else {
			image = NSImage(systemSymbolName: "car", accessibilityDescription: nil)
		}
		
		guard let first = cluster.memberAnnotations.first as? AGFitRadarAnnotation else {
			return
		}
		
		cluster.title = "Vehicles"
		let radarAnnotations = cluster.memberAnnotations as? [AGFitRadarAnnotation]
		cluster.subtitle = radarAnnotations?.reduce(first.radarTitle) { ($0) + ($1.radarDescription ?? "") }
		
		
	}
	
	

}
