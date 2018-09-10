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
	@IBOutlet weak var leftHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var rightView: UIView!
	@IBOutlet weak var rightHeightConstraint: NSLayoutConstraint!

	var height:CGFloat = 0.0

	public func cell( header: String, data: DiffArray? ) {
		showDiffs.text = header
		
		guard let data = data else {
			let ghost = GhostLine()
			ghost.text = " "
			ghost.show = true
			ghost.add = false
			ghost.remove = false
			height = 2.0
			leftView.addSubview( getLabel( entry: ghost) )
			height = 2.0
			rightView.addSubview( getLabel( entry: ghost ) )
			rightHeightConstraint.constant = 2.0
			leftHeightConstraint.constant = 2.0
			return
		}
		for view in leftView.subviews {
			view.removeFromSuperview()
		}
		for view in rightView.subviews {
			view.removeFromSuperview()
		}

		height = 2.0
		for entry in data.leftLines {
			leftView.addSubview( getLabel( entry: entry ) )
			height += 12.0
		}
		leftHeightConstraint.constant = height + 2.0
		height = 2.0
		for entry in data.rightLines {
			rightView.addSubview( getLabel( entry: entry ) )
			height += 12.0
		}
		rightHeightConstraint.constant = height + 2.0
	}
	
	private func getLabel( entry: GhostLine ) -> UILabel {
		
		let label = UILabel( frame: CGRect(x:  0.0, y: height, width: leftView.frame.size.width, height: 12.0) )
		label.numberOfLines = 1
		label.font = UIFont.systemFont(ofSize: 12.0)
		label.lineBreakMode = .byClipping
		label.text = entry.text
		label.textColor = entry.show ? .black : .white
		if entry.add {
			label.backgroundColor = UIColor( red: 0.0, green: 0.0, blue: 1.0, alpha: 0.2)
		}
		if entry.remove {
			label.backgroundColor = UIColor( red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
		}
		return label
	}
	
}
