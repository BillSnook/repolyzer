//
//  SessionManager.swift
//  repolyzer
//
//  Created by William Snook on 9/7/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import Foundation

public typealias RepoResponse = ( _ data: Data, _ error: Error? ) -> Void

let authenticateKey = "billsnook:sidewinder1.1"


enum Sources: String {
	case pull_requests		= "repos/magicalpanda/MagicalRecord/pulls"
}

class SessionManager {
	
	let repoSession = URLSession(configuration: .default)
	var dataTask: URLSessionDataTask?
	var repoName = "MagicRecord"
	var errorMessage = ""
	
	init( _ withRepo: String? ) {
		guard let newRepoName = withRepo,
			  !newRepoName.isEmpty else { return }
		repoName = newRepoName
	}
	
	func sendRequest( _ request: Sources, completion: @escaping RepoResponse) {

		var urlComps = "https://api.github.com/" + request.rawValue
		if var urlComponents = URLComponents(string: urlComps) {
			urlComponents.query = "state=open"
			guard let url = urlComponents.url else { return }
			var urlRequest = URLRequest.init(url: url)
			urlRequest.setValue( "Basic \(authenticateKey)", forHTTPHeaderField: "Authorization" )
			dataTask = repoSession.dataTask(with: urlRequest) { data, response, error in
				defer { self.dataTask = nil }
				if let error = error {
					self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
				} else if let data = data,
					let response = response as? HTTPURLResponse,
					response.statusCode == 200 {
					
					completion(data, nil)
				}
			}
			dataTask?.resume()
		}
	}
}
