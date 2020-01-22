//
//  NetworkManager.swift
//  Finplicity
//
//  Created by Matt Lichtenstein on 1/21/20.
//  Copyright © 2020 Matt Lichtenstein. All rights reserved.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    let baseUrl = "https://development.plaid.com"
    var accessToken = ""
    
    private init() {}
    
    func getAccessToken(publicToken: String, completed: @escaping (String?, String?) -> Void) {
        let endpoint = baseUrl + "/item/public_token/exchange"
        let url = URL(string: endpoint)!
        let parameters = ["client_id": FNConstants.clientID, "secret": FNConstants.developmentSecret, "public_token": publicToken]
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                    guard let jsonP = json["access_token"] else {
                        return
                    }
                        self.accessToken = jsonP as! String
                    
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    
    func getTransactions(completed: @escaping (String?, String?) -> Void) {

        let endpoint = baseUrl + "/transactions/get"
        let url = URL(string: endpoint)!
        let parameters = ["client_id": FNConstants.clientID, "secret": FNConstants.developmentSecret, "access_token": self.accessToken, "start_date": "2020-01-01", "end_date": "2020-01-20"]
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    
}
