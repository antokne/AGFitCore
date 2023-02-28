//
//  AGFitCourse.swift
//  FitViewer
//
//  Created by Antony Gardiner on 13/02/23.
//  Copyright © 2023 WahooFitness. All rights reserved.
//

import Foundation
import AGCore
import FitDataProtocol
import MapKit

public class AGFitCourseViewModel: NSObject {
	
	private var formatter = AGFormatter.sharedFormatter
	
	public var course: CourseMessage?
	public var lap: LapMessage?
	public var coursePoints: [CoursePointMessage] = []
	
	public init(course: CourseMessage? = nil, lap: LapMessage? = nil) {
		self.course = course
		self.lap = lap
	}
	
	public func addCoursePoint(coursePoint: CoursePointMessage) {
		coursePoints.append(coursePoint)
	}
	
	public  var estimatedDuration: String {
		if let duration = lap?.totalElapsedTime?.value {
			return formatter.formatDuration(duration: duration)
		}
		return "?"
	}
	
	public var ascentFormatted: String {
		if let ascent = lap?.totalAscent?.value {
			return formatter.formatValue(value: ascent, using: UnitLength.meters, usingProvidedUnit: true, withDecimalPoints: 0)
		}
		return "?"
	}
	
}


public class WFFitCoursePoint: NSObject {
	private var coursePoint: CoursePointMessage
	
	public init(coursePoint: CoursePointMessage) {
		self.coursePoint = coursePoint
	}

//	AGImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond", accessibilityDescription: "right arrow")
	public var image: AGImage? {
		if #available(macOS 11.0, *) {
			return coursePoint.pointType?.image
		} else {
			return nil
		}
	}
}

extension WFFitCoursePoint: MKAnnotation {
	
	public var title: String? {
		coursePoint.name
	}
	
	public var coordinate: CLLocationCoordinate2D {
		
		if let lat = coursePoint.position?.latitude?.converted(to: .degrees).value,
		   let lng = coursePoint.position?.longitude?.converted(to: .degrees).value {
			return CLLocationCoordinate2D(latitude: lat, longitude: lng)
		}
		return CLLocationCoordinate2D()
	}
	
}

extension CoursePoint {
	@available(macOS 11.0, iOS 13.0, *)
	public var image: AGImage? {
		switch self {
		case .generic:
			return AGImage(systemSymbolName: "circle", accessibilityDescription: "just a circle")
		case .summit:
			return AGImage(systemSymbolName: "photo.circle", accessibilityDescription: "right arrow")
		case .valley:
			return AGImage(systemSymbolName: "arrow.triangle.turn.up.right.diamond", accessibilityDescription: "right arrow")
		case .water:
			return AGImage(systemSymbolName: "drop", accessibilityDescription: "water")
		case .food:
			return AGImage(systemSymbolName: "fork.knife.circle", accessibilityDescription: "food")
		case .danger:
			return AGImage(systemSymbolName: "exclamationmark.octagon", accessibilityDescription: "danger")
		case .left:
			return AGImage(systemSymbolName: "arrow.left", accessibilityDescription: "left arrow")
		case .right:
			return AGImage(systemSymbolName: "arrow.right", accessibilityDescription: "right arrow")
		case .straight:
			return AGImage(systemSymbolName: "arrow.up", accessibilityDescription: "right straight")
		case .firstAid:
			return AGImage(systemSymbolName: "stethoscope.circle", accessibilityDescription: "stethoscope circle")
		case .fourthCategory:
			return AGImage(systemSymbolName: "4.circle", accessibilityDescription: "4th cat climb")
		case .thirdCategory:
			return AGImage(systemSymbolName: "3.circle", accessibilityDescription: "3rd cat climb")
		case .secondCategory:
			return AGImage(systemSymbolName: "2.circle", accessibilityDescription: "2nd cat climb")
		case .firstCategory:
			return AGImage(systemSymbolName: "1.circle", accessibilityDescription: "1st cat climb")
		case .horsCategory:
			return AGImage(systemSymbolName: "exclamationmark.circle", accessibilityDescription: "hors cat climb")
		case .sprint:
			return AGImage(systemSymbolName: "figure.run.circle", accessibilityDescription: "sprint")
		case .leftFork:
			return AGImage(systemSymbolName: "circle", accessibilityDescription: "left fork")
		case .rightFork:
			return AGImage(systemSymbolName: "circle", accessibilityDescription: "right fork")
		case .middleFork:
			return AGImage(systemSymbolName: "circle", accessibilityDescription: "middle fork")
		case .slightLeft:
			return AGImage(systemSymbolName: "arrow.up.left", accessibilityDescription: "slight left")
		case .sharpLeft:
			return AGImage(systemSymbolName: "arrow.down.left", accessibilityDescription: "sharp left")
		case .slightRight:
			return AGImage(systemSymbolName: "arrow.up.right", accessibilityDescription: "slight right")
		case .sharpRight:
			return AGImage(systemSymbolName: "arrow.down.right", accessibilityDescription: "sharp right")
		case .uTurn:
			return AGImage(systemSymbolName: "arrow.uturn.backward", accessibilityDescription: "u turn")
		case .segmentStart:
			return AGImage(systemSymbolName: "circle", accessibilityDescription: "segment start")
		case .segmentEnd:
			return AGImage(systemSymbolName: "circle", accessibilityDescription: "segment end")
		case .invalid:
			return AGImage(systemSymbolName: "exclamationmark.octagon", accessibilityDescription: "exclamationmark octagon")
		}
	}
}
