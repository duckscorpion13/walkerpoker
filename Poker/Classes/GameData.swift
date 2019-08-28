//
//  GameData.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class GameData: NSManagedObject {
    @NSManaged var credits	: NSNumber
    @NSManaged var totalBet: NSNumber
    @NSManaged var totalWon: NSNumber
	@NSManaged var usedSteps: NSNumber
	@NSManaged var dueDay: Date
	
	
    class func gameData() -> GameData? {
//		guard let appDelegate	= UIApplication.shared.delegate as? AppDelegate else {
//			return nil
//		}
//		guard let context	= appDelegate.managedObjectContext else {
//			return nil
//		}
		let context = CoreDataMgr.shared.managedObjectContext
		let request	= NSFetchRequest<GameData>(entityName: "GameData")
		var gameData: GameData?
		
		if let results = try? context.fetch(request), results.count > 0 {
			gameData = results[0]
		} else {
			if let gameData = NSEntityDescription.insertNewObject(forEntityName: "GameData", into: context) as? GameData {
				gameData.credits = 100
				gameData.dueDay = Date()
				CoreDataMgr.shared.saveContext()
			}
		}
		
		return gameData
	}
	
	func saveData() {
//		(UIApplication.shared.delegate as? AppDelegate)?.saveContext()
		CoreDataMgr.shared.saveContext()
	}
	
	func betCredits(amount: Int) {
		self.credits = NSNumber(value: self.credits.intValue - amount)
		self.totalBet = NSNumber(value: self.totalBet.intValue + amount)
		self.saveData()
	}
	
	func winCredits(amount: Int) {
		self.credits = NSNumber(value: self.credits.intValue + amount)
		self.totalWon = NSNumber(value: self.totalWon.intValue + amount)
		self.saveData()
	}
	
	func getTodaySteps() -> Int {
		if(!self.dueDay.isToday()) {
			self.usedSteps = 0
			self.dueDay = Date()
			self.saveData()
		}
		return self.usedSteps.intValue
	}
	
	func addCredits(steps: Int, rate: Int = 10) {
		self.credits = NSNumber(value: self.credits.intValue + steps / rate)
		self.usedSteps = NSNumber(value: self.getTodaySteps() + steps)
		self.saveData()
	}
}

