//
//  FirstViewController.swift
//  Example
//
//  Created by Thomas Gilbert on 28/05/2017.
//  Copyright © 2017 Thomas Gilbert. All rights reserved.
//

import UIKit
import remote_controllable

class FirstViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = URLRequest(url: URL(string: "http://www.dr.dk")!)
        webView.loadRequest(request)
    }
    
    @IBAction func doSupport(_ sender: UIButton) {
        RemoteControllableApp.sharedInstance.isConnected() ?
            RemoteControllableApp.sharedInstance.stopConnection() :
            RemoteControllableApp.sharedInstance.startConnection("http://localhost:8006", uuid: "SOMEID")
    }
}

