//
//  Date+.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation

extension Date {
	func isSameDay(with otherDay: Date) -> Bool {
		let dformatter = DateFormatter()
		dformatter.dateFormat = "yyyyMMdd"
		
		return dformatter.string(from: self) == dformatter.string(from: otherDay)
	}
	
	func isSameMonth(with otherDay: Date) -> Bool {
		let dformatter = DateFormatter()
		dformatter.dateFormat = "yyyyMM"
		
		return dformatter.string(from: self) == dformatter.string(from: otherDay)
	}
	
	func isToday() -> Bool {
		return isSameDay(with: Date())
	}
	
	func isTheMonth() -> Bool {
		return isSameMonth(with: Date())
	}
}
