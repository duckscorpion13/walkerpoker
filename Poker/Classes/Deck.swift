//
//  Deck.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation
import Swift

class Deck {
	var cards = [Card]()
	var position	= 0
	
	init() {
		for suit in Card.Suit.allSuits {
			for rank in Card.Rank.allRanks {
				self.cards.append(Card(rank: rank, suit: suit))
			}
		}
	}
	
    final subscript (position: Int) -> Card {
		get {
			return self.cards[position]
		}
	}
	
	func shuffle() {
		self.position = 0
		self.cards.shuffle()
	}
	
	func drawCard() -> Card {
		let card = self.cards[self.position]
		
		self.position += 1
		card.reset()

		return card
	}
}

