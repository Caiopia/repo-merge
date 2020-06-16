//
//  ViewController.swift
//  swift-tvos
//
//  Created by Steve Kirkland on 12/06/2020.
//  Copyright © 2020 Bugsnag. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var apiKey: String = "YOUR-API-KEY"
    var config: BugsnagConfiguration

    required init?(coder: NSCoder) {
        config = BugsnagConfiguration(apiKey)
        super.init(coder: coder)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        config = BugsnagConfiguration(apiKey)
    }


    /*
     * Configure
     */
    @IBAction func rsProduction(_ sender: Any) {
        config.releaseStage = "production"
    }

    @IBAction func rsCI(_ sender: Any) {
        config.releaseStage = "CI"
    }
    
    @IBAction func persistUser(_ sender: Any) {
        config.setUser("Ms User", withEmail:"Not@real.fake", andName:"The Default User")
        config.persistUser = true
    }
    
    @IBAction func clearData(_ sender: Any) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
    
    /*
     * Starting Bugsnag
     */
    @IBAction func startFromPlist(_ sender: Any) {
        Bugsnag.start()
    }
    
    @IBAction func startWithApiKey(_ sender: Any) {
        Bugsnag.start(withApiKey: apiKey)
    }
    
    @IBAction func startWithConfig(_ sender: Any) {

        config.appVersion = "1.5.0"
        config.redactedKeys = ["password", "credit_card_number"]
        config.enabledReleaseStages = ["production", "release"]

        Bugsnag.start(with: config)
    }
    
    @IBAction func manualSessions(_ sender: Any) {
        config.appVersion = "2.6.0"
        config.redactedKeys = ["password", "credit_card_number"]
        config.enabledReleaseStages = ["production", "release"]
        config.autoTrackSessions = false
        
        Bugsnag.start(with: config)
    }
    
    
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
        
    /**
     This method causes a signal from the operating system to terminate the app.  Upon reopening the app this signal should be notified to your Bugsnag dashboard.
     */
    @IBAction func signal(_ sender: Any) {
        AnObjCClass().trap()
    }
    
    
    @IBAction func closeApp(_ sender: Any) {
        exit(0)
    }
}

