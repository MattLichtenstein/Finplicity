//
//  ViewController.swift
//  Finplicity
//
//  Created by Matt Lichtenstein on 1/16/20.
//  Copyright © 2020 Matt Lichtenstein. All rights reserved.
//

import UIKit
import LinkKit

class ViewController: UIViewController {
    
    let addAccBtn = UIButton()
    var publicToken = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupAddAccBtn()
    }

    func setupAddAccBtn() {
        view.addSubview(addAccBtn)
        addAccBtn.backgroundColor = .systemGray2
        addAccBtn.layer.cornerRadius = 10
        addAccBtn.setTitle("Add Account", for: .normal)
        addAccBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addAccBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addAccBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            addAccBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            addAccBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        addAccBtn.addTarget(self, action: #selector(setupPlaidDelegates), for: .touchUpInside)
    }
    
    @objc func setupPlaidDelegates() {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
        present(linkViewController, animated: true)
    }
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Success", message: "token: \(publicToken)\nmetadata: \(metadata ?? [:])")
    }

    func handleError(_ error: Error, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }
    
    func handleExitWithMetadata(_ metadata: [String : Any]?) {
        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
    }
    
    func presentAlertViewWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}

extension ViewController : PLKPlaidLinkViewDelegate {
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
    
        self.publicToken = publicToken

        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
            NetworkManager.shared.getAccessToken(publicToken: publicToken) { (accessToken, error) in
                if let _ = error {
                    print ("there was an error")
                } else {
                    print(accessToken!)
                }
            }
            
            NetworkManager.shared.getTransactions() { (x, y) in
                if let _ = y {
                    print ("there was an error")
                } else {
                    print(x!)
                }
            }
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
                
        dismiss(animated: true) {
                   if let error = error {
                       NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                       self.handleError(error, metadata: metadata)
                   }
                   else {
                       NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
                       self.handleExitWithMetadata(metadata)
                   }
               }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didHandleEvent event: String, metadata: [String : Any]?) {
        
        NSLog("Link event: \(event)\nmetadata: \(metadata ?? [:])")
    }
}


