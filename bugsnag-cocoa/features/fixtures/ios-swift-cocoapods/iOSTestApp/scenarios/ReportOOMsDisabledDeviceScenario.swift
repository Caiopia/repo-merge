//
// Created by Jamie Lynch on 06/03/2018.
// Copyright (c) 2018 Bugsnag. All rights reserved.
//

import Foundation
import Bugsnag

/**
 * Sends a handled Error to Bugsnag
 */
class ReportOOMsDisabledDeviceScenario: Scenario {
    
    override func startBugsnag() {
        self.config.shouldAutoCaptureSessions = false
        self.config.reportOOMs = false
        super.startBugsnag()
    }
    
    override func run() {
        let webview = UIWebView.init()
        let format = NSString.init(string: "var b = document.createElement('div'); div.innerHTML = 'Hello item %d'; document.documentElement.appendChild(div);")
        let end = 3000 * 1024
        for i in 0...end {
            let item = NSString.localizedStringWithFormat(format, String(i))
            webview.stringByEvaluatingJavaScript(from: String(item))
            if (i % 1000 == 0) {
                NSLog("Loaded %d items", i);
            }
        }
    }
    
}
