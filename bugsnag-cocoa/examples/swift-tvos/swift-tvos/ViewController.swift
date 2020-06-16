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
        NSLog("Config created with API key: " + apiKey)
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
        NSLog("Start from plist")
        Bugsnag.start()
    }
    
    @IBAction func startWithApiKey(_ sender: Any) {
        NSLog("Start with API key")
        Bugsnag.start(withApiKey: apiKey)
    }
    
    @IBAction func startWithConfig(_ sender: Any) {
        NSLog("Start with config")

        config.appVersion = "1.5.0"
        config.redactedKeys = ["password", "credit_card_number"]

        Bugsnag.start(with: config)
    }
    
    @IBAction func manualSessions(_ sender: Any) {
        NSLog("Start from config with manual sessions")
        
        config.appVersion = "2.6.0"
        config.redactedKeys = ["password", "credit_card_number"]
        config.autoTrackSessions = false
        
        Bugsnag.start(with: config)
    }
    
    
    /*
     * Handled errors
     */
    @IBAction func notifyException(_ sender: Any) {
        NSLog("Notify handled exception")
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
        NSLog("Notify handled error")
        
        Bugsnag.leaveBreadcrumb("This is a breadcrumb with metadata",
                                metadata: ["authoer": "steve", "volume": 11], type: BSGBreadcrumbType.process)
        
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
        NSLog("Uncaught exception")

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
    
    /*
     * Session control
     */
    
    @IBAction func startSession(_ sender: Any) {
        Bugsnag.startSession()
    }
    
    @IBAction func pauseSession(_ sender: Any) {
        Bugsnag.pauseSession()
    }
    
    @IBAction func resumeSession(_ sender: Any) {
        Bugsnag.resumeSession()
    }
}

