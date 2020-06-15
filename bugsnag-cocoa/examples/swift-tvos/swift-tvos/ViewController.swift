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
        textView.text = ""
    }

    @IBOutlet weak var textView: UITextView!

    /*
     * Handled errors
     */
    @IBAction func notifyException(_ sender: Any) {
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
    
    @IBAction func notifyError(_ sender: Any) {
        do {
            throw NSError(domain: "com.bugsnag.example", code: 101, userInfo: [NSLocalizedDescriptionKey: "A handled error"])
        }
        catch let error as NSError {
            Bugsnag.notifyError(error)
        }
    }
    
    /*
     * Unhandled errors
     */
    @IBAction func uncaughtException(_ sender: Any) {
        let someJson : Dictionary = ["foo":self]
        do {
            let data = try JSONSerialization.data(withJSONObject: someJson, options: .prettyPrinted)
            print("Received data: %@", data)
        } catch {
            // Why does this crash the app? A very good question.
        }
    }
    
    @IBAction func stackOverflow(_ sender: Any) {
        let items = ["I'll overflow!"]
        if sender is ViewController || sender is UIButton {
            stackOverflow(self)
        }
        print("items: %@", items)
    }
    
    @IBAction func oom(_ sender: Any) {
        let text = "var b = document.createElement('div'); div.innerHTML = 'Hello item %d'; document.documentElement.appendChild(div);\n";
        for i in 0 ... (3000 * 1024) {
            textView.text += text;
            textView.setNeedsLayout()
            if (i % 500 == 0) {
                NSLog("Loaded %d items", i);
            }
        }

    }
    
    
}

