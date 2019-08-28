//
//  Game.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation

class Game {
	enum State {
		case ready
		case dealt
		case complete(result: Hand.Category)
	}

	static var shared	= Game()
	static let maxBet	= 5

	var deck	= Deck()
	var hand	= Hand()
	var gameData: GameData?
	
	var betHandler: ((_ newBet: Int) -> Void)? = nil
	var evHandler: ((_ newEV: Double?) -> Void)? = nil
	var stateHandler: ((_ newState: State) -> Void)? = nil
	var lastWin = 0
	
	var canDeal: Bool { if case .ready = self.state, self.bet != 0 { return true } else { return false } }
	var credits: Int { return self.gameData?.credits.intValue ?? 0 }

	var actualBet: Int = 0 {
		didSet(oldValue) {
			self.betHandler?(self.bet)
		}
	}
	
    var bet: Int {
		set (newValue) {
			var actualValue = (newValue > Game.maxBet) ? Game.maxBet : newValue
			var betDelta = actualValue - self.actualBet
			
			if (betDelta > self.credits) {
				actualValue -= betDelta - self.credits
				betDelta = actualValue - self.actualBet
			}
			
			if case .complete = self.state, actualValue > 0 {
				self.state = .ready
			}
			
			if self.actualBet != actualValue {
				self.gameData?.betCredits(amount: betDelta)
				self.actualBet = actualValue
			}
		}
	
		get {
			return self.actualBet
		}
	}
	
	var state: State = State.ready {
		willSet(newValue) {
			switch newValue {
				case .ready:
					self.actualBet = 0
					self.lastWin = 0
					self.evHandler?(nil)
				
				case .dealt:
					//self.calculateEV()
					break
				default:
					self.actualBet = 0
					break
			}
			self.stateHandler?(newValue)
		}
	}
	

	// MARK: - Lifecycle
	
	required init() {
		self.gameData = GameData.gameData()		
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Betting
	
	func incrementBet(amount: Int = Game.maxBet) {
		if case .complete = self.state  {
			self.state = .ready
		}		
		self.bet += amount
	}
	
	func decrementBet(amount: Int = Game.maxBet) {
		if case .ready = self.state {
			if(self.bet > 0) {
				self.bet -= amount
			}
		}
	}
	
	func betMax() {
		self.incrementBet(amount: Game.maxBet)
	}
	
	// MARK: - Cards
	
	func handCard(at index: Int) -> Card? {
		return self.hand[index]
	}
	
	@discardableResult func deal() -> Bool {
		var isDealt = false
		
		if self.canDeal {
			self.deck.shuffle()
			self.hand.initialDrawFromDeck(self.deck)
			self.state = .dealt
			isDealt = true
		}
		
		return isDealt
	}

	@discardableResult func draw() -> Bool {
		var isDrew = false
		
		if case .dealt = self.state {
			let result	: Hand.Category
			
			self.hand.drawFromDeck(self.deck)
			result = self.hand.evaluate()
			self.lastWin = result.payoutForBet(self.actualBet)
			if self.lastWin > 0 {
				self.gameData?.winCredits(amount: self.lastWin)
			}
			self.state = .complete(result: result)
			isDrew = true
		}
		
		return isDrew
	}
}
