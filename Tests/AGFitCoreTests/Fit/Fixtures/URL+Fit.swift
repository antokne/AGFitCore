//
//  UTL Fit.swift
//  
//
//  Created by Antony Gardiner on 22/05/23.
//

import Foundation

extension URL {
	static func fitURL(name: String, ext: String) -> URL? {
		
		guard let fitFile = Bundle.module.url(forResource: name, withExtension: ext) else {
			return nil
		}
		return fitFile
	}
	
	static func tempFitFile() -> URL? {
		let tempDir = FileManager.default.temporaryDirectory
		
		var url = URL(string: UUID().uuidString, relativeTo: tempDir)
		url?.appendPathExtension("fit")
		return url
	}
}
