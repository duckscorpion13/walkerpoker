//
//  CardSet.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import Foundation

struct CardSet: OptionSet {
	static let royalStraight	= CardSet(ranks: [.ace, .king, .queen, .jack, .ten])
	static let allStraights: [CardSet] = [
									royalStraight,
									CardSet(ranks: [.king, .queen, .jack, .ten, .nine]),
									CardSet(ranks: [.queen, .jack, .ten, .nine, .eight]),
									CardSet(ranks: [.jack, .ten, .nine, .eight, .seven]),
									CardSet(ranks: [.ten, .nine, .eight, .seven, .six]),
									CardSet(ranks: [.nine, .eight, .seven, .six, .five]),
									CardSet(ranks: [.eight, .seven, .six, .five, .four]),
									CardSet(ranks: [.seven, .six, .five, .four, .three]),
									CardSet(ranks: [.six, .five, .four, .three, .two]),
									CardSet(ranks: [.five, .four, .three, .two, .ace])
								]
	
	let rawValue	: UInt64

	var cards: [Card] {
		var setBits = self.rawValue
		var cards = [Card]()
		var bitCount	= 0

		while setBits != 0 {
			if setBits & 1 != 0 {
				if let rank = Card.Rank(rawValue: bitCount % 16),
				let suit = Card.Suit(rawValue: bitCount / 16) {
					cards.append(Card(rank: rank, suit: suit))
				}
			}
			bitCount += 1
			setBits >>= 1
		}

		return cards
	}
	
	init(rawValue: UInt64) {
		self.rawValue = rawValue
	}
	
	init(card: Card) {
		self = CardSet(rawValue: card.cardSetValue)
	}
	
	init(cards: [Card]) {
		self = CardSet(rawValue: cards.reduce(0, { (result, card) -> UInt64 in result | card.cardSetValue }))
	}
	
	init(ranks: [Card.Rank]) {		// mask maker
		self = CardSet(rawValue: ranks.reduce(0, { (result, rank) -> UInt64 in result | UInt64(rank.rankBit) }))
	}
	
    func eval() -> (category: Hand.Category, relevant: CardSet) {

		let clubRanks = (self.rawValue >> Card.Suit.club.shiftVal) & Card.Suit.rankMask
		let diamondRanks = (self.rawValue >> Card.Suit.diamond.shiftVal) & Card.Suit.rankMask
		let heartRanks = (self.rawValue >> Card.Suit.heart.shiftVal) & Card.Suit.rankMask
		let spadeRanks = (self.rawValue >> Card.Suit.spade.shiftVal) & Card.Suit.rankMask
		let suitRanks = [clubRanks, diamondRanks, heartRanks, spadeRanks]
		let any2Raw: [UInt64] = [
							clubRanks & diamondRanks,
							clubRanks & heartRanks,
							clubRanks & spadeRanks,
							diamondRanks & heartRanks,
							diamondRanks & spadeRanks,
							heartRanks & spadeRanks
						]
		var any2	= CardSet(rawValue: any2Raw.reduce(0, { (result, rawValue) -> UInt64 in result | rawValue }))

		if !any2.isEmpty {
			let any3Raw: [UInt64] = [
								clubRanks & diamondRanks & heartRanks,
								clubRanks & diamondRanks & spadeRanks,
								heartRanks & spadeRanks & clubRanks,
								heartRanks & spadeRanks & diamondRanks
							]

			let any3 = CardSet(rawValue: any3Raw.reduce(0, { (result, rawValue) -> UInt64 in result | rawValue }))
			if !any3.isEmpty {
				let any4 = CardSet(rawValue: clubRanks & diamondRanks & heartRanks & spadeRanks)//any3Raw[0] & suitRanks[Card.Suit.spade.rawValue])
				
				if !any4.isEmpty {
					return (category: .fourOfAKind, relevant: CardSet(rawValue: Card.Suit.allSuits.reduce(UInt64(0), { $0 | (any4.rawValue << $1.shiftVal) })))
				} else {
					any2.subtract(any3)
					
					if !any2.isEmpty {
						return (category: .fullHouse, relevant: self)
					} else {
						let rankValue = any3.rawValue.firstNonzeroBitPosition
						
						return (category: .threeOfAKind, relevant: CardSet(cards: self.cards.filter({ $0.rank.rawValue == rankValue })))
					}
				}
			} else {
				if any2.rawValue.nonzeroBitCount > 1 {
					let rankValues = any2.rawValue.nonzeroBitPositions

					return (category: .twoPair, relevant: CardSet(cards: self.cards.filter({ card in rankValues.contains(where: { card.rank.rawValue == $0 }) })))
				} else {
					if any2.rawValue >= (1 << Card.Rank.jack.rawValue) {
						if let rankValue = any2.rawValue.firstNonzeroBitPosition {
							return (category: .jacksOrBetter, relevant: CardSet(cards: self.cards.filter({ $0.rank.rawValue == rankValue })))
						} else {	// shouldn't be possible
							return (category: .none, relevant: [])
						}
					} else {
						return (category: .none, relevant: [])
					}
				}
			}
		} else {				// Only bother with this if there are no pairs or better
			let allSuitBits	= Card.Suit.allSuits.reduce(UInt64(0), { (result, suit) -> UInt64 in result | suitRanks[suit.rawValue] })
			let hasStraight	= CardSet.allStraights.contains(where: { allSuitBits == $0.rawValue })

			for suitBits in suitRanks {
				if hasStraight {
					for straight in CardSet.allStraights {
						let rawValue	= straight.rawValue

						if suitBits == rawValue {
							return (category: straight == CardSet.royalStraight ? .royalFlush : .straightFlush, relevant: self)
						}
					}
				} else if suitBits.nonzeroBitCount == Consts.Game.MaxHandCards {
					return (category: .flush, relevant: self)
				}
			}
			
			return hasStraight ? (category: .straight, relevant: self) : (category: .none, relevant: [])
		}
    }
}

