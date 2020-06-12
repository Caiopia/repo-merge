//
//  ViewController.swift
//  swift-tvos
//
//  Created by Steve Kirkland on 12/06/2020.
//  Copyright © 2020 Bugsnag. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func notify(_ sender: Any) {
        do {
            try FileManager.default.removeItem(atPath:"//invalid/file")
        } catch {
            Bugsnag.notifyError(error) { event in
                // modify report properties in the (optional) block
                event.severity = .info
                return true
            }
        }
    }

    @IBAction func uncaughtException(_ sender: Any) {
        let someJson : Dictionary = ["foo":self]
        do {
            let data = try JSONSerialization.data(withJSONObject: someJson, options: .prettyPrinted)
            print("Received data: %@", data)
        } catch {
            // Why does this crash the app? A very good question.
        }
    }
}

