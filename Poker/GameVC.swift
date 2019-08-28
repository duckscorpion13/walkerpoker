//
//  GameController.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class GameVC: UIViewController {
	// MARK: - Variables

	@IBOutlet weak var paytableView: PayTableView!
	@IBOutlet weak var betLabel: UILabel!
	@IBOutlet weak var creditsLabel: UILabel!
	@IBOutlet weak var winLabel: UILabel!
	@IBOutlet weak var dealDrawButton: UIButton!
	@IBOutlet weak var betMaxButton: UIButton!
	@IBOutlet weak var betOneButton: UIButton!

	var m_closeBtn: DragButton? = nil
	
	var cardViews: [CardView]?
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.view.backgroundColor = .darkgreen
		
		setupCloseBtn()
		
		Game.shared.betHandler = { (newBet: Int) -> () in
			self.updateElements(gameState: Game.shared.state)
			self.paytableView.bet = newBet
		}
		
		
		Game.shared.stateHandler = { (newState: Game.State) -> () in
			// transitions here, while updateElements can be called at any point
			if let cardViews = self.cardViews {
				switch newState {
					case .ready:
						self.paytableView.category = .none
						for cardView in cardViews {
							cardView.card = nil
							cardView.isRevealed = false
						}
					case .dealt:
						for cardView in cardViews {
							let card	= Game.shared.handCard(at: cardView.tag - Consts.Views.CardViewTagStart)
							
							cardView.card = card
						}
						self.resetAllCards()
						for cardView in cardViews {
							cardView.setRevealed(value: true, animated: true)
							cardView.isEnabled = true
						}
				
					case .complete(let result):
						var revealCount = 0
						var dispatchTime	= TimeInterval(0)
						
						for cardView in cardViews {
							cardView.isEnabled = false
							if !cardView.isRevealed {
								let card	= Game.shared.handCard(at: cardView.tag - Consts.Views.CardViewTagStart)
							
								cardView.card = card
								cardView.setRevealed(value: true, animated: true)
								revealCount += 1
							}
							else {
								cardView.card?.hold = false
								cardView.update()
							}
						}
						if revealCount > 0 {
							// card flip + a slight pause to allow player a moment to recognize before we do
							dispatchTime = (0.2 + Consts.Views.RevealAnimationTime)
						}
						delay(dispatchTime) {
							self.paytableView.category = result
							for cardView in cardViews {
								cardView.animatePinned()
							}
						}
				}
			}
		
			self.updateElements(gameState: newState)
		}

		self.resetViews()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.resetAllCards()
	}

	func setupCloseBtn()
	{
		self.m_closeBtn = DragButton(frame: CGRect.zero)
		
		if let btn = self.m_closeBtn {
			
			let image = UIImage(named: "close")
			btn.setImage(image, for: .normal)
			//            btn.addTarget(self, action: #selector(clickClose), for: .touchUpInside)
			btn.clickClosure = {
				[weak self]
				(btn) in
				//单击回调
				self?.dismiss(animated: true)
			}
			self.view.addSubview(btn)
			btn.translatesAutoresizingMaskIntoConstraints = false
			if #available(iOS 11.0, *) {
				btn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
				btn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
			} else {
				// Fallback on earlier versions
				self.edgesForExtendedLayout = []
				
				btn.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
				btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
			}
			btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
			btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
		}
	}
	
	func resetViews() {
		if self.cardViews == nil {
			let viewTag	= Consts.Views.CardViewTagStart
			let cardViews = (viewTag..<viewTag + 5).compactMap({ self.view.viewWithTag($0) as? CardView })
			
			for cardView in cardViews {
				cardView.update()
			}
			
			self.cardViews = cardViews
			self.updateElements(gameState: Game.shared.state)
		}
		
		self.betLabel.text = String(Game.shared.bet)
		self.creditsLabel.text = String(Game.shared.credits)
		self.winLabel.text = String(Game.shared.lastWin)
	}
	
	
	func resetAllCards(animated: Bool = false) {
		guard let cardViews	= self.cardViews else { return }
		
		for cardView in cardViews {
			cardView.setRevealed(value: false, animated: animated)
			cardView.resetPinned()
		}
	}
	
	func updateElements(gameState: Game.State) {
		switch gameState {
			case .ready:
				self.betMaxButton.isEnabled = true
				self.betOneButton.isEnabled = true
				self.dealDrawButton.isEnabled = Game.shared.bet > 0
			case .dealt:
				self.betMaxButton.isEnabled = false
				self.betOneButton.isEnabled = false
				self.dealDrawButton.isEnabled = true
			case .complete:
				self.betMaxButton.isEnabled = true
				self.betOneButton.isEnabled = true
				self.dealDrawButton.isEnabled = false
		}
		self.betLabel.text = String(Game.shared.bet)
		self.creditsLabel.text = String(Game.shared.credits)
		self.winLabel.text = String(Game.shared.lastWin)
	}
	
	// MARK: - Handlers

	@IBAction func handleRemoveOne(_ sender: Any) {
		if case .complete = Game.shared.state  {
			self.resetAllCards()
			Game.shared.state = .ready
			Game.shared.decrementBet(amount: 1)
		} else {
			Game.shared.decrementBet(amount: 1)
		}
	}
	@IBAction func handleBetOne(_ sender: AnyObject) {
		if case .complete = Game.shared.state  {
			self.resetAllCards()
			Game.shared.state = .ready
			Game.shared.incrementBet(amount: 1)
		} else {
			Game.shared.incrementBet(amount: 1)
		}
	}

	@IBAction func handleBetMax(_ sender: AnyObject?) {
		if case .complete = Game.shared.state  {
			self.resetAllCards()
			Game.shared.state = .ready
			Game.shared.betMax()
			Game.shared.deal()
		} else {
			Game.shared.betMax()
			Game.shared.deal()
		}
	}

	@IBAction func handleDealDraw(_ sender: AnyObject) {
		switch Game.shared.state {
			case .ready:
				Game.shared.deal()

			case .dealt:
				var hideCount		= 0
				var dispatchTime	= TimeInterval(0.0)
				
				if let cardViews = self.cardViews {
					for cardView in cardViews {
						guard let card = cardView.card else { continue }
						
						if !card.hold {
							hideCount += 1
							cardView.setRevealed(value: false, animated: true)
						}
					}
				}
				
				if hideCount > 0 {
					dispatchTime = 0.15 + Consts.Views.RevealAnimationTime	// card flip + a little extra time to "think"
				}
				delay(dispatchTime) { Game.shared.draw() }

			case .complete:
				break
		}
	}
}
