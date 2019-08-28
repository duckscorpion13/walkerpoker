//
//  Hand.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Swift

class Hand {
	var cards: [Card] { return self.cardSlots.compactMap({ $0 }) }
	var cardSet: CardSet { return CardSet(rawValue: self.cardSlots.reduce(UInt64(0), { (result, slot) -> UInt64 in slot.map({ result | $0.cardSetValue }) ?? result })) }
	var heldCards: [Card] { return self.cards.filter({ $0.hold })}
	private var cardSlots	= [Card?](repeating: nil, count: Consts.Game.MaxHandCards)
	
    subscript (position: Int) -> Card? {
		get { return self.cardSlots[position] }
		set { self.cardSlots[position] = newValue }
	}

	func initialDrawFromDeck(_ deck: Deck) {
		self.cardSlots = [Card?](repeating: nil, count: Consts.Game.MaxHandCards)
		self.drawFromDeck(deck)

		print("draw: \(self.cards)")
	}
	
	func drawFromDeck(_ deck: Deck) {
		for (index, value) in self.cardSlots.enumerated() {
			if (value == nil || !value!.hold) {
				self.cardSlots[index] = deck.drawCard()
			}
		}
//		self.cardSlots = [Card(rank: .seven, suit: .heart),
//						Card(rank: .three, suit: .heart),
//						Card(rank: .two, suit: .club),
//						Card(rank: .two, suit: .heart),
//						Card(rank: .two, suit: .spade)
//						]
	}
	
	func evaluate() -> Category {
		let cardSet		= self.cardSet
		let evaluation	= cardSet.eval()

		print("eval: \(self.cards) = \(evaluation)")
		
		if !evaluation.relevant.isEmpty {
			for card in self.cards {
				card.pin = evaluation.relevant.contains(CardSet(card: card))
			}
		}
		
		return evaluation.category
	}
	
	/* --- Category --- */

	enum Category: Int, CustomStringConvertible {
		case none = 0
		case jacksOrBetter
		case twoPair
		case threeOfAKind
		case straight
		case flush
		case fullHouse
		case fourOfAKind
		case straightFlush
		case royalFlush

		static let WinningCategories	= [royalFlush, straightFlush, fourOfAKind, fullHouse, flush, straight, threeOfAKind, twoPair, jacksOrBetter]
		static let NumCategories		= royalFlush.rawValue + 1
		
		var description: String {
			get {
				switch self {
					case .none:
						return "None"
					case .jacksOrBetter:
						return "Jacks or Better"
					case .twoPair:
						return "Two Pair"
					case .threeOfAKind:
						return "Three of a Kind"
					case .straight:
						return "Straight"
					case .flush:
						return "Flush"
					case .fullHouse:
						return "Full House"
					case .fourOfAKind:
						return "Four of a Kind"
					case .straightFlush:
						return "Straight Flush"
					case .royalFlush:
						return "Royal Flush"
				}
			}
		}
		
		func payoutForBet(_ bet: Int) -> Int {
			var payout = 0
			
			switch self {
				case .none:
					payout = 0
				case .jacksOrBetter:
					payout = 1
				case .twoPair:
					payout = 2
				case .threeOfAKind:
					payout = 4
				case .straight:
					payout = 5
				case .flush:
					payout = 6
				case .fullHouse:
					payout = 10
				case .fourOfAKind:
					payout = 25
				case .straightFlush:
					payout = 50
				case .royalFlush:
					payout = 200
			}
			
			payout *= bet
			
			return payout
		}
	}
}
