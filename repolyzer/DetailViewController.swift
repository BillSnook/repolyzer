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

	var diffData: Data?

	func configureView() {
		guard let data = diffData else { return }
		if let label = self.detailDescriptionLabel {
			label.text = String( data: data, encoding: String.Encoding.utf8 )
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
}

