//
//  Card.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

// MARK: - Globals

func ==(lhs: Card, rhs: Card) -> Bool {
	return lhs.rank == rhs.rank && lhs.suit == rhs.suit
}

func <(lhs: Card, rhs: Card) -> Bool {
	return lhs.rank < rhs.rank
}

func <(lhs: Card.Rank, rhs: Card.Rank) -> Bool {
	return lhs.rawValue < rhs.rawValue
}

// MARK: - Card

class Card: Comparable, CustomStringConvertible {
	final let rank: Rank
	final let suit: Suit
	var pin = false		// indicates a card that is part of the current hand's category
	var hold = false
	var cardSetValue: UInt64 { return UInt64(self.rank.rankBit) << self.suit.shiftVal }
    var description: String { return rank.description + suit.description }
    var fullDescription: String { return rank.fullDescription + suit.fullDescription }

	init(rank: Card.Rank, suit: Card.Suit) {
		self.rank = rank
		self.suit = suit
	}

	func reset() {
		self.pin = false
		self.hold = false
	}
	
	// MARK: - Rank
	
	enum Rank: Int, Comparable, CustomStringConvertible {
		case two = 0, three, four, five, six, seven, eight, nine, ten
		case jack, queen, king, ace

		static let minRank	= Rank.two
		static let maxRank	= Rank.ace
		static let numRanks	= Rank.maxRank.rawValue + 1
		static let allRanks	: [Rank] = [.two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king, .ace]

		init?(rankStr: String) {
			switch rankStr {
				case "A":
					self = .ace
				case "K":
					self = .king
				case "Q":
					self = .queen
				case "J":
					self = .jack
				case "T":
					self = .ten
				case "9":
					self = .nine
				case "8":
					self = .eight
				case "7":
					self = .seven
				case "6":
					self = .six
				case "5":
					self = .five
				case "4":
					self = .four
				case "3":
					self = .three
				case "2":
					self = .two
				default:
					return nil
			}
		}
		
		var identifier: String { return self.description }
		var rankBit: UInt { return UInt(1 << self.rawValue) }
		var description: String {
			get {
				switch self {
					case .ace:
						return "A"
					case .king:
						return "K"
					case .queen:
						return "Q"
					case .jack:
						return "J"
					case .ten:
						return "T"
					case let someRank where someRank.rawValue >= Rank.two.rawValue && someRank.rawValue <= Rank.nine.rawValue:
						return String(someRank.rawValue + 2)
					default:
						return "?"
				}
			}
		}

		var fullDescription	: String {
			get {
				switch self {
					case .ace:
						return "Ace"
					case .king:
						return "King"
					case .queen:
						return "Queen"
					case .jack:
						return "Jack"
					case let someRank where someRank.rawValue >= Rank.two.rawValue && someRank.rawValue <= Rank.ten.rawValue:
						return String(someRank.rawValue + 2)
					default:
						return "?"
				}
			}
		}

		var nextHigher		: Rank? { return self != Rank.ace ? Rank(rawValue: self.rawValue + 1) : nil }
		var nextLower		: Rank? { return self != Rank.two ? Rank(rawValue: self.rawValue - 1) : nil }
	}

	// MARK: - Suit

	enum Suit: Int, CustomStringConvertible {
		case club = 0, diamond, heart, spade
		
		static let minSuit = Suit.club
		static let maxSuit = Suit.spade
		static let numSuits = Suit.maxSuit.rawValue + 1
		static let allSuits: [Suit] = [.club, .diamond, .heart, .spade]
		static let rankMask = UInt64(0x1FFF)	// 13 bits

		var shiftVal	: UInt64 { return UInt64(self.rawValue * 16) }
		var identifier: String {
			get {
				switch self {
					case .club:
						return "C"
					case .diamond:
						return "D"
					case .heart:
						return "H"
					case .spade:
						return "S"
				}
			}
		}
		
		var description: String {
			get {
				switch self {
					case .club:
						return "♣︎"	// "♣️"
					case .diamond:
						return "♦︎"	// "♦️"
					case .heart:
						return "♥︎"	// "♥️"
					case .spade:
						return "♠︎"	// "♠️"
				}
			}
		}

		var fullDescription: String {
			get {
				switch self {
					case .club:
						return "Club"
					case .diamond:
						return "Diamond"
					case .heart:
						return "Heart"
					case .spade:
						return "Spade"
				}
			}
		}
	}
}

