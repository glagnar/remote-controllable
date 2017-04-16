//
//  SecondViewController.swift
//  Example
//
//  Created by Thomas Gilbert on 01/02/16.
//  Copyright © 2016 Alexandra Institute. All rights reserved.
//

import UIKit
import WebKit

class SecondViewController: UIViewController {

    @IBOutlet weak var webContainer: UIView!
    
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let request = URLRequest(url: URL(string: "http://www.dr.dk")!)
        webView?.load(request)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        // self.webView?.snapshotViewAfterScreenUpdates(true)
        self.view = self.webView
    }
}
