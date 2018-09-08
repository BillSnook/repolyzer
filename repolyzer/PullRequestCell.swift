//
//  PullRequestCell.swift
//  repolyzer
//
//  Created by William Snook on 9/8/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import UIKit

class PullRequestCell: UITableViewCell {
	@IBOutlet weak var pullRequestNumber: UILabel!
	@IBOutlet weak var pullRequestState: UILabel!
	@IBOutlet weak var pullRequestTitle: UILabel!
	
	public func cell( number: Int, state: String, title: String ) {
		pullRequestNumber.text = "#" + String( number )
		pullRequestState.text = state
		pullRequestTitle.text = title
	}
}
