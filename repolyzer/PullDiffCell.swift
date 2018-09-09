//
//  PullDiffCell.swift
//  repolyzer
//
//  Created by William Snook on 9/9/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import UIKit

class PullDiffCell: UITableViewCell {
	@IBOutlet weak var showDiffs: UILabel!
	
	@IBOutlet weak var leftView: UIView!
	@IBOutlet weak var leftLabel: UILabel!
	
	@IBOutlet weak var rightView: UIView!
	@IBOutlet weak var rightLabel: UILabel!
	
	
	public func cell( header: String, list: String ) {
		showDiffs.text = header
		leftLabel.text = list
		rightLabel.text = list
	}
}
