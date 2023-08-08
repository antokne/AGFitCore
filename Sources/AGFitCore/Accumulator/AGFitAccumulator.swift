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
		
		guard let recordDate = record.timeStamp?.recordDate else {
			print("Not timestamp cannot add.")
			return
		}
		
		do {
			
			if let speed = record.speed?.value {
				try accumulate(date: recordDate, value: speed, type: .speed)
			}
			
			if let distance = record.distance?.value {
				try accumulate(date: recordDate, value: distance, type: .distance)
			}
			
			if let power = record.power?.value {
				try accumulate(date: recordDate, value: power, type: .power)
			}
			
			if let heartrate = record.heartRate?.value {
				try accumulate(date: recordDate, value: heartrate, type: .hr)
			}
			
			if let cadence = record.cadence?.value {
				try accumulate(date: recordDate, value: cadence, type: .cadence)
			}
			
			if let temperature = record.temperature?.value {
				try accumulate(date: recordDate, value: temperature, type: .temperature)
			}
			
			if let lrBalance = record.leftRightBalance?.percentContribution {
				try accumulate(date: recordDate, value: Double(lrBalance), type: .lrBalance)
			}
		}
		catch {
			print("failed to accumulate \(error).")
		}

	}
	
	public func event(event: EventMessage) {
		guard let recordDate = event.timeStamp?.recordDate else {
			print("Not timestamp cannot add.")
			return
		}
		
		switch event.eventType {
		case .start:
			// Need to handle messages coming from fit. the first start message should start the accumulator.
			if self.state == .stopped {
				self.event(event: .start, at: recordDate)
			}
			else {
				self.event(event: .resume, at: recordDate)
			}
		case .stop:
			// This is a pause in disguise
			self.event(event: .pause, at: recordDate)
			break
		case .stopAll:
			// The actual stop.
			self.event(event: .stop, at: recordDate)
		default:
			print("event not handled \(event)")
			break
		}
	}
	
	
	
}
