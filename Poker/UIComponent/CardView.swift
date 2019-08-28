//
//  CardView.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import QuartzCore

class CardView: UIView, CAAnimationDelegate {
	var cardImage: UIImageView? = nil
	var holdLabel: UILabel? = nil
	var isEnabled = false
	var card	: Card?
	var isRevealed = false
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CardView.handleTap(_:))))
		
		setupUI() 
	}
	
	func imageNameForCard(_ card: Card) -> String {
		var imageName = "card_"
		
		imageName += card.rank.identifier + card.suit.identifier
		
		return imageName
	}
	
	func setupUI() {
		self.cardImage = UIImageView(image: UIImage(named: "card_back"))
		if let imgView = self.cardImage {
			self.addSubview(imgView)
			imgView.translatesAutoresizingMaskIntoConstraints = true
			imgView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor)
			
			self.holdLabel = UILabel(frame: .zero)
			if let lbl = self.holdLabel {
				lbl.text = "HOLD"
				lbl.font = .boldSystemFont(ofSize: 20)
				lbl.backgroundColor = .black
				lbl.textColor = .yellow
				lbl.textAlignment = .center
				self.addSubview(lbl)
				lbl.translatesAutoresizingMaskIntoConstraints = true
				lbl.center(in: imgView, width: 60, height: 35)
			}			
		}
	}
	
	func update() {
		if let card = self.card, self.isRevealed {
			self.holdLabel?.isHidden = !card.hold
			self.cardImage?.image = UIImage(named: self.imageNameForCard(card))
		} else {
			self.holdLabel?.isHidden = true
			self.cardImage?.image = UIImage(named: "card_back")
		}
	}
	
	func setRevealed(value: Bool, animated: Bool = false) {
		if value != self.isRevealed {
			self.isRevealed = value
			if animated {
				self.beginReveal(clockwise: self.isRevealed)
			} else {
				self.update()
			}
		}
	}
	
	func animatePinned() {
		guard let card = self.card else {
			return
		}
		
		if !card.pin {
			UIView.animate(withDuration: Consts.Views.PinAnimationTime) {
				self.alpha = 0.35
			}
		}
	}
	
	func resetPinned() {
		self.alpha = 1.00
	}
	
	@objc func handleTap(_ recognizer: UIGestureRecognizer) {
		guard let card = self.card, self.isEnabled else { return }

		card.hold = !card.hold
		self.update()
		
		NotificationCenter.default.post(name: NSNotification.Name(rawValue: Consts.Notifications.RefreshEV), object: card)
	}
	
	func beginReveal(clockwise: Bool = true) {
		let flipAnimation	= CABasicAnimation(keyPath: "transform")
		var endTransform	= CATransform3DIdentity
		let endAngle		= CGFloat.pi / (clockwise ? -2.0 : 2.0)
		
		endTransform.m34 = -1.0 / 500.0
		endTransform = CATransform3DRotate(endTransform, endAngle, 0, 1, 0)
		flipAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
		flipAnimation.toValue = NSValue(caTransform3D: endTransform)
		flipAnimation.duration = Consts.Views.RevealAnimationTime / 2.0
		flipAnimation.setValue(NSNumber(value: clockwise), forKey: "clockwise")
		flipAnimation.delegate = self
		self.cardImage?.layer.transform = endTransform
		self.cardImage?.layer.add(flipAnimation, forKey: "begin_reveal")
	}
	
	func finishReveal(clockwise: Bool = true) {
		let flipAnimation	= CABasicAnimation(keyPath: "transform")
		var startTransform	= CATransform3DIdentity
		let endTransform	= CATransform3DIdentity
		let startAngle		= CGFloat.pi / (clockwise ? -2.0 : 2.0)
		
		self.update()
		startTransform.m34 = -1.0 / 500.0
		startTransform = CATransform3DRotate(startTransform, startAngle, 0, 1, 0)
		flipAnimation.fromValue = NSValue(caTransform3D: startTransform)
		flipAnimation.toValue = NSValue(caTransform3D: endTransform)
		flipAnimation.duration = Consts.Views.RevealAnimationTime / 2.0
		self.cardImage?.layer.transform = endTransform
		self.cardImage?.layer.add(flipAnimation, forKey: "end_reveal")
	}
	
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		guard let clockwise = anim.value(forKey: "clockwise") as? NSNumber else { return }
		
		self.finishReveal(clockwise: clockwise.boolValue)
	}
}
