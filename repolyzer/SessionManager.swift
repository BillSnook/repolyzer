//
//  SessionManager.swift
//  repolyzer
//
//  Created by William Snook on 9/7/18.
//  Copyright © 2018 billsnook. All rights reserved.
//

import Foundation

public typealias RepoResponse = ( _ data: Data?, _ error: Error? ) -> Void


class SessionManager {
	
	let repoSession: URLSession // = URLSession(configuration: .default)
	var dataTask: URLSessionDataTask?
	
	init() {
		repoSession = URLSession(configuration: .default)
	}
	
	func sendRequest( _ request: String, completion: @escaping RepoResponse) {

		var urlComps = request
		if var urlComponents = URLComponents(string: urlComps) {
			urlComponents.query = "state=open"
			guard let url = urlComponents.url else { return }
			var urlRequest = URLRequest.init(url: url)
			dataTask = repoSession.dataTask(with: urlRequest) { data, response, error in
				defer { self.dataTask = nil }
				if let error = error {
					completion(nil, error)
				} else if let data = data,
					let response = response as? HTTPURLResponse,
					response.statusCode == 200 {
					
					completion(data, nil)
				} else {
					completion(nil, nil)
				}
			}
			dataTask?.resume()
		}
	}
}
