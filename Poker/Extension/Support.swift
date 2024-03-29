//
//  Support.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import UIKit

// ---
// MARK: - Dispatch -
// ----

func delay(_ delay: Double, qos: DispatchQoS.QoSClass = DispatchQoS.QoSClass.unspecified, closure: @escaping ()->()) {
	let queue = qos == DispatchQoS.QoSClass.unspecified ? DispatchQueue.main : DispatchQueue.global(qos: qos)

	queue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

func dispatch_async(_ qos: DispatchQoS.QoSClass = DispatchQoS.QoSClass.unspecified, closure: @escaping ()->()) {
	let queue = qos == DispatchQoS.QoSClass.unspecified ? DispatchQueue.main : DispatchQueue.global(qos: qos)

	queue.async(execute: closure)
}

func dispatch_on_main(_ closure: @escaping ()->()) {
	if Thread.isMainThread {
		closure()
	}
	else {
		dispatch_async(closure: closure)
	}
}

// ---
// MARK: - Misc Extenions -
// ----

extension NSMutableParagraphStyle {
	class func forDefaultStyle() -> NSMutableParagraphStyle {
		let style	= NSMutableParagraphStyle()
		
		style.setParagraphStyle(NSParagraphStyle.default)
		
		return style
	}
}

extension FixedWidthInteger {
	var nonzeroBitPositions		: [Int] {
		return (0..<self.bitWidth).compactMap({ (self & (1 << $0)) != 0 ? $0 : nil })
	}

	var firstNonzeroBitPosition	: Int? {
		return (0..<self.bitWidth).first(where: { (self & (1 << $0)) != 0 })
	}
}
