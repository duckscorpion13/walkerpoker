//
//  MyCollectionViewCell.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit

class MyCollectionViewCell: UICollectionViewCell {
	var date: Date! {
		didSet {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "M/d"
			let dateStr = dateFormatter.string(from: date)
			titleLabel.text =  dateStr
			if(date.isTheMonth()) {
				self.backgroundColor = date.isToday() ? .blue : .black
			} else {
				self.backgroundColor = .white
			}
			
			self.contextLabel.textColor = (self.date < Date()) ? .red : .black
		}
	}
	var steps: Int = 0 {
		didSet {
			self.contextLabel.text = "\(steps)"
		}
	}
	
	var titleLabel: UILabel!
	var contextLabel: UILabel!
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = .white
		
		let titleHeight: CGFloat = 40.0
		titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: titleHeight))
		titleLabel.textAlignment = .center
		titleLabel.textColor = .white
		self.addSubview(titleLabel)
		
		contextLabel = UILabel(frame: CGRect(x: 0, y: frame.height - titleHeight, width: frame.width, height: titleHeight))
		contextLabel.textAlignment = .right
		contextLabel.font = .systemFont(ofSize: 10)
		contextLabel.text = ""
		contextLabel.textColor = .red
		self.addSubview(contextLabel)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
