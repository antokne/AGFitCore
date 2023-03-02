//
//  AGFitAccumulator.swift
//  
//
//  Created by Antony Gardiner on 1/03/23.
//

import Foundation
import AGCore
import FitDataProtocol

// A Fit accumulator gets it's data from a fit file.
// using e.g. Record message data to accumulate instant data into averages etc.
// these this can then be used to be able to edit the fit file data
// and later write it back to a new fit file and us the accumulated data
// to create the lap and sessions records as needed.
//
// First off the rank will be simple single session fit files.
// edit record messages and update new lap/session records.
//
// It's worth noting that this will never be exactly the same as the original data
// that is recorded on a computer and the fit file data is normalised to 1 Hz.

public class AGFitAccumulator: AGAccumulator {
	
	
	/// Add details from record message into accumulated data
	/// - Parameter record: fit record message
	public func accumulateRecord(record: RecordMessage) {
		
		guard let timeInterval = record.timeStamp?.recordDate?.timeIntervalSinceReferenceDate else {
			print("Not timestamp cannot add.")
			return
		}
		
		if let speed = record.speed?.value {
			accumulate(timeInterval: timeInterval, value: speed, type: .speed)
		}
		
		if let distance = record.distance?.value {
			accumulate(timeInterval: timeInterval, value: distance, type: .distance)
		}
		
		if let power = record.power?.value {
			accumulate(timeInterval: timeInterval, value: power, type: .power)
		}

		if let heartrate = record.heartRate?.value {
			accumulate(timeInterval: timeInterval, value: heartrate, type: .hr)
		}

		if let cadence = record.cadence?.value {
			accumulate(timeInterval: timeInterval, value: cadence, type: .cadence)
		}

		if let temperature = record.temperature?.value {
			accumulate(timeInterval: timeInterval, value: temperature, type: .temperature)
		}

		if let lrBalance = record.leftRightBalance?.percentContribution {
			accumulate(timeInterval: timeInterval, value: Double(lrBalance), type: .lrBalance)
		}

	}
	
	public func event(event: EventMessage) {
		guard let timeInterval = event.timeStamp?.recordDate?.timeIntervalSinceReferenceDate else {
			print("Not timestamp cannot add.")
			return
		}
		
		switch event.eventType {
		case .start:
			self.event(event: .resume, at: timeInterval)
		case .stop:
			self.event(event: .pause, at: timeInterval)
			break
		default:
			break
		}
	}
	
	
	
}
