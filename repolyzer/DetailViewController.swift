//
//  DetailViewController.swift
//  repolyzer
//
//  Created by William Snook on 9/6/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import UIKit


let showRawData = false		// For testing

let maxDiffRows = 8
let nominalSectionHeaderHeight: CGFloat = 36.0


class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var detailDescriptionLabel: UILabel!
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var diffTable: UITableView!
	
	@IBOutlet weak var diffTitle: UILabel!
	@IBOutlet weak var diffNumber: UILabel!
	@IBOutlet weak var diffState: UILabel!
	
	var pullRequest: PullRequest?
	var diffData: Data?
	
	var viewModel: DetailViewModel?

	func configureView() {
		
		guard let data = diffData else {
			if let label = self.detailDescriptionLabel {
				headerView.isHidden = true
				diffTable.isHidden = true
				label.isHidden = false
				label.textAlignment = .left
				label.text = "Diffs are being accessed - please wait"
			}
			return
		}
		if let label = self.detailDescriptionLabel {
			if showRawData {
				label.isHidden = false
				label.textAlignment = .left
				label.text = String( data: data, encoding: String.Encoding.utf8 )
			} else {
				label.isHidden = true
			}
		}

		if showRawData {
			headerView.isHidden = true
			diffTable.isHidden = true
		} else {
			viewModel = DetailViewModel( with: data )
			headerView.isHidden = false
			diffTable.isHidden = false
			diffTable.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let num = pullRequest?.number {
			diffNumber?.text = "#" + String( num )
		}
		diffState?.text = pullRequest?.state
		diffTitle?.text = pullRequest?.title

//		configureView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func viewDidLayoutSubviews() {
		DispatchQueue.main.async {
			self.diffTable.reloadData()
		}
	}

	public func getResponse( _ data: Data?, _ error: Error? ) -> Void {
	
		if let err = error {
			showAlert(title: "Warning", message: "Error from sendRequest: \(err.localizedDescription)")
			return
		}
		guard let data = data, !data.isEmpty else {
			showAlert(title: "Warning", message: "No data received from sendRequest")
			return
		}
		if data.count > 500000 {
			showAlert(title: "Warning", message: "Data received is way too long - \(data.count) bytes!")
			return
		}
		self.diffData = data
		
		DispatchQueue.main.async {
			self.configureView()
		}
	}
	
	func showAlert( title: String, message: String ) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(defaultAction)
		present(alertController, animated: true, completion: nil)
	}
	
	// Mark - TableView delegate and source
	func numberOfSections(in tableView: UITableView) -> Int {
		if let count = viewModel?.diffList.count {
			return count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if var rows = viewModel?.diffList[section].diffLines.count {
			if rows > maxDiffRows {
				rows = 1
			}
			return rows
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let pdCell = tableView.dequeueReusableCell(withIdentifier: "PullDiffCell", for: indexPath) as! PullDiffCell
		
		guard let diffEntry = viewModel?.diffList[indexPath.section] else { return pdCell }
		if diffEntry.diffLines.count > maxDiffRows {
			pdCell.cell( header: "Too many diffs to display", data: nil )
			return pdCell
		}
		let diffLineHeader = diffEntry.diffLines[indexPath.row].lineRange
		pdCell.cell( header: diffLineHeader, data: diffEntry.diffArray[indexPath.row] )
		return pdCell
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection: Int) -> CGFloat {
		
		return nominalSectionHeaderHeight
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection: Int) -> UIView? {
		
		let view = UIView( frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.size.width, height: nominalSectionHeaderHeight))
		let label = UILabel( frame: CGRect(x: 8.0, y: 0.0, width: tableView.frame.size.width, height: nominalSectionHeaderHeight))
		let fileName = viewModel?.diffList[viewForHeaderInSection].fileName
		label.font = UIFont.systemFont( ofSize: 20.0 )
		label.text = fileName ?? "Missing filename"
		label.backgroundColor = UIColor( red: 120/255, green: 160/255, blue: 1.0, alpha: 0.8)
		view.addSubview( label )
		return view
	}
}

