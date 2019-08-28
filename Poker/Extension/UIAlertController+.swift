//
//  UIAlertController+.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
	
	class func hintAction(title: String, message: String) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "OK", style: .cancel)
		alert.addAction(okAction)
		
		return alert
	}
	
	class func checkAction(title: String, message: String, callback: @escaping () -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			callback()
		}
		alert.addAction(okAction)
		
		return alert
	}
	
	class func boolAction(title: String, message: String, callback: @escaping (Bool) -> ()) -> UIAlertController {
		return selectAction(title: title, message: message, actions: ["YES", "NO"]) {
			value in callback(value == 0)
		}
	}
	
	class func selectAction(title: String, message: String, actions: [String], callback: @escaping (Int) -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		for action in actions {
			let act = UIAlertAction(title: action, style: .default) {
				_ in
				callback(actions.firstIndex(of: action) ?? -1)
			}
			alert.addAction(act)
		}
		
		return alert
	}
	
	class func textsAlert(title: String, message: String, placeholders: [String], callback: @escaping ([String]) -> ()) -> UIAlertController {
		
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		
		for placeholder in placeholders {
			alert.addTextField {
				textField in
				textField.placeholder = placeholder
			}
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		alert.addAction(cancelAction)
		
		let okAction = UIAlertAction(title: "OK", style: .default) {
			_ in
			var paras = [String]()
			if let fields = alert.textFields {
				for field in fields{
					let para = field.text ?? ""
					paras.append(para)
				}
			}
			callback(paras)
		}
		alert.addAction(okAction)
		
		return alert
	}
}


extension UIViewController {
	func checkPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
		if let popoverController = viewControllerToPresent.popoverPresentationController {
			popoverController.sourceView = self.view
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
			popoverController.permittedArrowDirections = []
		}
		self.present(viewControllerToPresent, animated: flag, completion: completion)
	}
}
