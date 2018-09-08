//
//  DetailViewController.swift
//  repolyzer
//
//  Created by William Snook on 9/6/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

	@IBOutlet weak var detailDescriptionLabel: UILabel!


	func configureView() {
		if let detail = detailItem {
		    if let label = detailDescriptionLabel {
		        label.text = detail.title
		    }
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		configureView()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	var detailItem: PullRequest? {
		didSet {
		    configureView()		// Update the view
		}
	}


}

