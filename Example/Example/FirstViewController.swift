//
//  FirstViewController.swift
//  Example
//
//  Created by Thomas Gilbert on 01/02/16.
//  Copyright © 2016 Alexandra Institute. All rights reserved.
//

import UIKit
import remote_controllable

class FirstViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = NSURLRequest(URL: NSURL(string: "http://www.dr.dk")!)
        webView.loadRequest(request)
    }

    @IBAction func doSupport(sender: UIButton) {
        RemoteControllableApp.sharedInstance.isConnected() ?
            RemoteControllableApp.sharedInstance.stopConnection() :
            RemoteControllableApp.sharedInstance.startConnection("http://yourserver:8006", uuid: "My UNIQUE ID")
    }
}

