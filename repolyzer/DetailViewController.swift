//
//  DetailViewController.swift
//  repolyzer
//
//  Created by William Snook on 9/6/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import UIKit


let showRawData = false		// For testing

let maxDiffRows =	4


class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var detailDescriptionLabel: UILabel!
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
			diffTable.isHidden = true
		} else {
			viewModel = DetailViewModel( with: data )
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

	public func getResponse( _ data: Data?, _ error: Error? ) -> Void {
	
		if let err = error {
			print( "Alert - error from sendRequest: \(err.localizedDescription)" )
			return
		}
		guard let data = data, !data.isEmpty else {
			print( "Alert - no data from sendRequest" )
			return
		}
		self.diffData = data
		
		DispatchQueue.main.async {
			self.configureView()
		}
	}
	
	// Mark - TableView delegate and source
	func numberOfSections(in tableView: UITableView) -> Int {
		if let count = viewModel?.diffList.diffEntries.count {
			return count
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if var rows = viewModel?.diffList.diffEntries[section].diffLines.count {
			if rows > maxDiffRows {
				rows = 1
			}
			return rows
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let pdCell = tableView.dequeueReusableCell(withIdentifier: "PullDiffCell", for: indexPath) as! PullDiffCell
		
		guard let diffEntry = viewModel?.diffList.diffEntries[indexPath.section] else { return pdCell }
		if diffEntry.diffLines.count > maxDiffRows {
			pdCell.cell( header: "Too many diffs to display", list: "" )
			return pdCell
		}
		let diffLineHeader = diffEntry.diffLines[indexPath.row].lineRange
		let diffLines = diffEntry.diffLines[indexPath.row].line
		pdCell.cell( header: diffLineHeader, list: diffLines )
		return pdCell
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection: Int) -> String? {
		
		let range = viewModel?.diffList.diffEntries[titleForHeaderInSection].fileName
		return range ?? "Missing filename"
	}

}

