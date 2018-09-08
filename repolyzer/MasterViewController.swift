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
	var session = SessionManager( "" )
	var pullRequests: [PullRequest] = []


	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let split = splitViewController {
		    let controllers = split.viewControllers
		    detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
		
		tableView.estimatedRowHeight = 64.0
		tableView.rowHeight = UITableViewAutomaticDimension
		
		session.sendRequest( .pull_requests, completion: getResponse )
	}

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


	public func getResponse( _ data: Data, _ error: Error? ) -> Void {
	
		let decoder = JSONDecoder()
		do {
			pullRequests = try decoder.decode([PullRequest].self, from: data)
			print( "Number of pull requests: \(pullRequests.count)" )
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		} catch {
			print("Error converting data to JSON")
			print(error)
		}

	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = tableView.indexPathForSelectedRow {
				let pr = pullRequests[indexPath.row]
		        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
		        controller.detailItem = pr
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

