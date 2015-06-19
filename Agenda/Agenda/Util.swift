//
//  Util.swift
//  Agenda
//
//  Created by Vitor Kawai Sala on 19/06/15.
//  Copyright (c) 2015 Melhor Grupo. All rights reserved.
//

import Foundation

class Util{
	static func nameRegex(name: String) -> Bool{
		let regexString = "^[a-zA-Z]([a-z0-9]| )*$"

		var error : NSError? = nil

		let regex = NSRegularExpression(pattern: regexString, options: NSRegularExpressionOptions.CaseInsensitive, error: &error)

		if (error != nil){
			println("Error: \(error?.localizedDescription)")
			return false
		}

		return regex!.numberOfMatchesInString(name, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(name))) > 0
	}
}