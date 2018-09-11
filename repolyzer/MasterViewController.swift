//
//  MasterViewController.swift
//  repolyzer
//
//  Created by William Snook on 9/6/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import UIKit

struct PullRequest: Codable {
	var url: String
	var id: Int
	var diff_url: String
	var number: Int
	var state: String
	var title: String
}

class MasterViewController: UITableViewController {

	var detailViewController: DetailViewController? = nil
	var session = SessionManager()
	var pullRequests: [PullRequest] = []

	var account = "magicalpanda"
	var repository = "MagicalRecord"

	override func viewDidLoad() {
		super.viewDidLoad()
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(bringUpModal(_:)))
		navigationItem.rightBarButtonItem = addButton

		if let split = splitViewController {
		    let controllers = split.viewControllers
		    detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
		
		tableView.estimatedRowHeight = 64.0
		tableView.rowHeight = UITableViewAutomaticDimension
		
	}

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)

		let defaults = UserDefaults.standard
		if let ud_account = defaults.string( forKey: "GithubAccount") {
			account = ud_account
		}
		if let ud_repository = defaults.string( forKey: "GithubRepository") {
			repository = ud_repository
		}
		
		session.sendRequest( "https://api.github.com/repos/\(account)/\(repository)/pulls", completion: getResponse )
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
		
		let decoder = JSONDecoder()
		do {
			pullRequests = try decoder.decode([PullRequest].self, from: data)
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		} catch {
			showAlert(title: "Warning", message: "Error converting data to JSON: \(error.localizedDescription)")
		}

	}

	func showAlert( title: String, message: String ) {
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(defaultAction)
		present(alertController, animated: true, completion: nil)
	}
	
	@objc
	func bringUpModal(_ sender: Any) {
		if let VC = self.storyboard?.instantiateViewController(withIdentifier: "ParamEntryVC") {
			self.present(VC, animated: true, completion: nil)
		}
		
	}
	

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = tableView.indexPathForSelectedRow {
				tableView.deselectRow( at: indexPath, animated: true )
				let pr = pullRequests[indexPath.row]
		        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
				controller.pullRequest = pr
				session.sendRequest( pr.diff_url, completion: controller.getResponse )
		        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return pullRequests.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let prCell = tableView.dequeueReusableCell(withIdentifier: "PullRequestCell", for: indexPath) as! PullRequestCell

		let pr = pullRequests[indexPath.row]
		prCell.cell( number: pr.number, state: pr.state, title: pr.title )
		return prCell
	}

}

