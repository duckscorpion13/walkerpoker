//
//  HealthVC.swift
//  WalkerPoker
//
//  Created by DSY on 2019/8/23.
//  Copyright © 2019 Mac. All rights reserved.
//

import UIKit
import HealthKit

class HealthVC: UIViewController {
	private let reuseIdentifier = "CollectionCell"
	let fullScreenSize = UIScreen.main.bounds.size
	var m_calendar: UICollectionView!
	
	var m_storage: HKHealthStore!
	let m_todayStepsLbl = UILabel()
	let m_coinLbl = UILabel()
	var m_todaySteps = 0
	
	var m_headerLbl = UILabel()
	
	var m_pastSteps = [String : Int]()
	
	var currentYear = Calendar.current.component(.year, from: Date())
	var currentMonth = Calendar.current.component(.month, from: Date())
	
	var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "1DEC"]
	
//	lazy var m_coreDataMgr: CoreDataMgr = {
//		return CoreDataMgr()
//	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.view.backgroundColor = .white
		
	
		
		let btnGame = UIButton(frame: .zero)
//		btn2.setTitle("Game", for: .normal)
//		btn2.setTitleColor(.blue, for: .normal)
		btnGame.setImage(UIImage(named: "croupier"), for: .normal)
		btnGame.addTarget(self, action: #selector(self.enterGame), for: .touchUpInside)
		self.view.addSubview(btnGame)
		btnGame.anchor(top: nil, left: nil, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, width: 60, height: 60)
		
		getAuthority()
		
		self.view.addSubview(m_headerLbl)
		self.m_headerLbl.font = UIFont.boldSystemFont(ofSize: 20)
		self.m_headerLbl.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 11.0, *) {
			self.m_headerLbl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
		} else {
			self.m_headerLbl.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25).isActive = true
		}
		self.m_headerLbl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		
		
		let layout = UICollectionViewFlowLayout()
		self.m_calendar = UICollectionView(frame: .zero, collectionViewLayout: layout)
		self.m_calendar.backgroundColor = .gray
		self.m_calendar.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//		self.m_calendar.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
		self.view.addSubview(m_calendar)
		self.m_calendar.anchor(top: self.m_headerLbl.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, width: nil, height: 320)
		
		
		self.m_calendar.delegate = self
		self.m_calendar.dataSource = self
		
		
		self.view.addSubview(m_todayStepsLbl)
		m_todayStepsLbl.textAlignment = .center
		m_todayStepsLbl.anchor(top: self.m_calendar.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, width: nil, height: 35)
		
		let btnExchange = UIButton(frame: .zero)
		btnExchange.setImage(UIImage(named: "exchange"), for: .normal)
//		btnExchange.setTitle("10:1", for: .normal)
//		btnExchange.setTitleColor(.black, for: .normal)
		btnExchange.addTarget(self, action: #selector(self.exchangeSteps), for: .touchUpInside)
		self.view.addSubview(btnExchange)
		btnExchange.anchor(top: m_todayStepsLbl.bottomAnchor, left: nil, bottom: nil, right: nil, width: 60, height: 60)
		btnExchange.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
		
		self.view.addSubview(m_coinLbl)
		m_coinLbl.textAlignment = .center
		m_coinLbl.anchor(top: btnExchange.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, width: nil, height: 35)
		
    }
	
	func setUp(){
		self.m_headerLbl.text = "Walking " +  months[currentMonth - 1] + " \(currentYear)"
		self.m_calendar.reloadData()
//		print(whatDayIsIt)
	}
	
	fileprivate func readTodaySteps() {
		self.readStepsCount() { steps in
			self.m_todaySteps = steps
			DispatchQueue.main.async {
				let usedSteps = GameData.gameData()?.getTodaySteps() ?? 0
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "MMdd"
				let dateStr = dateFormatter.string(from: Date())
				self.m_pastSteps[dateStr] = steps
				self.m_todayStepsLbl.text = "Today \(usedSteps)/\(steps) steps"
			}
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.navigationController?.isNavigationBarHidden = true
		self.readTodaySteps()
		
		setUp()
		
		self.m_coinLbl.text = "\(GameData.gameData()?.credits ?? 0)💰"
	}
	
	fileprivate func getManyDaysSteps(days: Int = 30) {
	
		let cal = Calendar(identifier: Calendar.Identifier.gregorian)
		let today = cal.startOfDay(for: Date())
		for beforeDay in 1 ... days {
			let date = today.addingTimeInterval(-Double(beforeDay) * 24 * 60 * 60)
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMdd"
			let dateStr = dateFormatter.string(from: date)
			self.readStepsCount(date: date) {  steps in
				self.m_pastSteps[dateStr] = steps
				if(days == self.m_pastSteps.count) {
					DispatchQueue.main.async {
						self.m_calendar.reloadData()
						self.m_coinLbl.text = "\(GameData.gameData()?.credits ?? 0)💰"
					}
				}
			}
		}
		
	}
	
	fileprivate func getSomeDaySteps(yyyymmdd: String, _ completion: @escaping (Int) -> () ) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyyMMdd"
		if let date = dateFormatter.date(from: yyyymmdd) {
			self.readStepsCount(date: date) {  steps in
				completion(steps)
			}
		}
	}
	
	@objc func enterGame() {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		if let vc = storyboard.instantiateViewController(withIdentifier: "GameVC") as? GameVC {
			if let navi = self.navigationController {
				navi.pushViewController(vc, animated: true)
			} else {
				self.present(vc, animated: true)
			}
		}
//		getSomeDaySteps(yyyymmdd: "20190820")
//		print(self.m_last30Steps)
	}
	
	@objc func exchangeSteps() {
		let amount = 100
		if let gameData = GameData.gameData() {
			let isEnough = (self.m_todaySteps - amount - gameData.usedSteps.intValue) >= 0
			if(isEnough) {
				gameData.addCredits(steps: amount)
				self.readTodaySteps()
				self.m_coinLbl.text = "\(Game.shared.credits)💰"
			} else {
				let alert = UIAlertController.hintAction(title: "Hint", message: "not enough")
				self.checkPresent(alert, animated: true)
			}
		}

		//			let logs = CoreDataMgr.shared.loadTodayLogs()
		//			for log in logs {
		//				print(log)
		//			}
	}
	
	func getAuthority() {
		if(HKHealthStore.isHealthDataAvailable()) {
			self.m_storage = HKHealthStore()
			let stepSet = Set(arrayLiteral: HKObjectType.quantityType(forIdentifier: .stepCount)!)
			self.m_storage.requestAuthorization(toShare: nil, read: stepSet) { (isSuccess, error) in
				if(isSuccess) {
					self.readTodaySteps()
					self.getManyDaysSteps()
				} else {
					let alert = UIAlertController.hintAction(title: "Hint", message: "not support")
					self.checkPresent(alert, animated: true)
				}
			}
		}
	}
	
	func readStepsCount(date: Date = Date(), _ completion: @escaping (Int) -> () ) {

		let cal = Calendar(identifier: Calendar.Identifier.gregorian)
		let newDate = cal.startOfDay(for: date)
		let endDate = cal.startOfDay(for: newDate.addingTimeInterval(24*60*60))
		//  Set the Predicates & Interval
		let predicate = HKQuery.predicateForSamples(withStart: newDate, end: endDate, options: .strictStartDate)
		var interval = DateComponents()
		interval.day = 1
		
		let stepType = HKSampleType.quantityType(forIdentifier: .stepCount)!
	
		
		//  Perform the Query
		let query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: [.cumulativeSum], anchorDate: newDate, intervalComponents: interval)
		
		query.initialResultsHandler = { query, results, error in
			
			if error != nil {
				
				//  Something went Wrong
				return
			}
			
			if let myResults = results{
				myResults.enumerateStatistics(from: newDate, to: Date()) {
					statistics, stop in
					
					if let quantity = statistics.sumQuantity() {
						
						let steps = Int(quantity.doubleValue(for: HKUnit.count()))
						
//						print("Steps = \(steps)")
						completion(steps)
		
					}
				}
			}
			
			
		}
		self.m_storage.execute(query)
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask  {
		return .portrait
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		self.m_calendar.collectionViewLayout.invalidateLayout()
		self.m_calendar.reloadData()
	}
	
	var numberOfDaysInThisMonth: Int
	{
		let dateComponents = DateComponents(year: currentYear, month: currentMonth)
		let date = Calendar.current.date(from: dateComponents)!
		let range = Calendar.current.range(of: .day, in: .month, for: date)
		return range?.count ?? 0
	}
	
	var whatDayIsFirst: Int
	{
		let dateComponents = DateComponents(year: currentYear, month: currentMonth)
		let date = Calendar.current.date(from: dateComponents)!
		return Calendar.current.component(.weekday, from: date)
	}
	
	var howManyItemsShouldIAdd: Int
	{
		return whatDayIsFirst - 1
	}
}

extension HealthVC: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return numberOfDaysInThisMonth + howManyItemsShouldIAdd
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MyCollectionViewCell
		
		let dayNum = indexPath.row + 1 - howManyItemsShouldIAdd
		let cal = Calendar(identifier: Calendar.Identifier.gregorian)
		let today = cal.startOfDay(for: Date())
		let todayNum = Calendar.current.component(.day, from: today)
		let beforeDays = todayNum - dayNum
		let date = today.addingTimeInterval(-Double(beforeDays) * 24 * 60 * 60)
		
		cell.date = date
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMdd"
		let dateStr = dateFormatter.string(from: date)
		if let steps = self.m_pastSteps[dateStr] {
			cell.steps = steps
		}
	
		
//		if indexPath.row < howManyItemsShouldIAdd{
//			cell.titleLabel.text = ""
//		} else {
//			let day = indexPath.row + 1 - howManyItemsShouldIAdd
//			cell.titleLabel.text = "\(day)"
		
//			let currentDate = Calendar.current.component(.day, from: Date())
//			cell.backgroundColor = .white
		
			
			
//			if(currentDate == day) {
//				cell.backgroundColor = .blue
//				print(indexPath.row)
//				cell.contextLabel.text = "\(self.m_todaySteps)"
//			} else {
//				if(currentDate > day) {
//					let cal = Calendar(identifier: Calendar.Identifier.gregorian)
//					let today = cal.startOfDay(for: Date())
//					let beforeDays = currentDate - day
//					if (beforeDays > 0) {
//						let date = today.addingTimeInterval(-Double(beforeDays) * 24 * 60 * 60)
//						let dateFormatter = DateFormatter()
//						dateFormatter.dateFormat = "MMdd"
//						let dateStr = dateFormatter.string(from: date)
//						cell.backgroundColor = .black
//						if let steps = self.m_last30Steps[dateStr] {
//							cell.contextLabel.text = "\(steps)"
//						}
//					}
//				}
//			}
//		}
		
		return cell
	}
	
	//单元格间距
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
	{
		return 1
	}

	//行间距
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
	{
		let row: CGFloat = 7
//		print(numberOfDaysInThisMonth)
//		print(howManyItemsShouldIAdd)
		let maxAdd = (numberOfDaysInThisMonth < 31) ? 5 : 4
		let col: CGFloat =  (howManyItemsShouldIAdd <= maxAdd) ? 5 : 6
		let width = (collectionView.frame.width - row + 1) / row
		let height = (collectionView.frame.height - col + 1) / col
		return CGSize(width: width, height: height)
	}
}
