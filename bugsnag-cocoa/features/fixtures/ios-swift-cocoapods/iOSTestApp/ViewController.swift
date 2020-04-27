//
//  ViewController.swift
//  iOSTestApp
//
//  Created by Delisa on 2/23/18.
//  Copyright © 2018 Bugsnag. All rights reserved.
//

import UIKit
import os

class ViewController: UIViewController {

    @IBOutlet var scenarioNameField : UITextField!
    @IBOutlet var scenarioMetaDataField : UITextField!
    var scenario : Scenario?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @IBAction func runTestScenario() {
        scenario = prepareScenario()
        
        NSLog("Starting Bugsnag for scenario: %@", String(describing: scenario))
        scenario?.startBugsnag()
        NSLog("Running scenario: %@", String(describing: scenario))
        scenario?.run()
    }

    @IBAction func startBugsnag() {
        scenario = prepareScenario()
        NSLog("Starting Bugsnag for scenario: %@", String(describing: scenario))
        scenario?.startBugsnag()
    }
    
    internal func prepareScenario() -> Scenario {
        let eventType : String! = scenarioNameField.text
        let eventMode : String! = scenarioMetaDataField.text
        
        let config = BugsnagConfiguration("ABCDEFGHIJKLMNOPQRSTUVWXYZ012345")
        config.endpoints = BugsnagEndpointConfiguration(notify: "http://bs-local.com:9339", sessions: "http://bs-local.com:9339")
        config.enabledErrorTypes = [.CPP, .Mach, .NSExceptions, .Signals]
        
        let scenario = Scenario.createScenarioNamed(eventType, withConfig: config)
        scenario.eventMode = eventMode
        return scenario
    }
    
    @objc func didEnterBackgroundNotification() {
        scenario?.didEnterBackgroundNotification()
    }
}

