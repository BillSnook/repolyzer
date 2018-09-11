//
//  ParamEntry.swift
//  repolyzer
//
//  Created by William Snook on 9/10/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import UIKit

class ParamEntryVC: UIViewController {
	
	@IBOutlet weak var githubAccount: UITextField!
	@IBOutlet weak var githubRepository: UITextField!

	var account = "magicalpanda"
	var repository = "MagicalRecord"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let defaults = UserDefaults.standard
		if let ud_account = defaults.string( forKey: "GithubAccount") {
			account = ud_account
		}
		if let ud_repository = defaults.string( forKey: "GithubRepository") {
			repository = ud_repository
		}

		if account.isEmpty {
			account = "magicalpanda"
		}
		if repository.isEmpty {
			repository = "MagicalRecord"
		}
		
		githubAccount.text = account
		githubRepository.text = repository
	}
	
	@IBAction func paramTouched(_ sender: Any) {
		print( "Touched" )
		
		var accountText = githubAccount.text
		var repositoryText = githubRepository.text

		if accountText == nil || accountText!.isEmpty {
			accountText = "magicalpanda"
		}
		if repositoryText == nil || repositoryText!.isEmpty {
			repositoryText = "MagicalRecord"
		}

		let defaults = UserDefaults.standard
		defaults.set( accountText, forKey: "GithubAccount" )
		defaults.set( repositoryText, forKey: "GithubRepository" )
		
		dismiss(animated: true, completion: nil)
	}

	func showAlert( title: String, message: String ) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(defaultAction)
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func cancelTouched(_ sender: Any) {

		dismiss(animated: true, completion: nil)
	}
	
}
