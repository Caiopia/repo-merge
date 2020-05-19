Feature: App and Device attributes present

Background:
    Given I set environment variable "BUGSNAG_API_KEY" to "a35a2a72bd230ac0aa0f52715bbdc6aa"

Scenario: App and Device info is as expected
    When I run "AppAndDeviceAttributesScenario"
    And I wait for a request
    Then the request is valid for the error reporting API
    And the "Bugsnag-API-Key" header equals "a35a2a72bd230ac0aa0f52715bbdc6aa"
    
    # Device
    
    And the payload field "events.0.device.osName" equals "iOS"
    And the payload field "events.0.device.osVersion" equals the device version
    And the payload field "events.0.device.jailbroken" is false
    And the payload field "events.0.device.osVersion" matches the regex "\d+\.\d+"
    And the payload field "events.0.device.manufacturer" equals "Apple"
    And the payload field "events.0.device.locale" equals "en_US"
    And the payload field "events.0.device.id" is not null
    And the payload field "events.0.device.model" equals "iPhone10,4"
    And the payload field "events.0.device.modelNumber" equals "simulator"
    And the payload field "events.0.device.runtimeVersions.osBuild" is not null
    And the payload field "events.0.device.runtimeVersions.clangVersion" is not null 
    And the payload field "events.0.device.totalMemory" is an integer

    # DeviceWithState

    And the payload field "events.0.device.freeDisk" is an integer
    And the payload field "events.0.device.freeMemory" is an integer
    And the payload field "events.0.device.orientation" equals "portrait"
    And the payload field "events.0.device.time" is not null
    And the payload field "events.0.device.time" is a date

    # App
    
    # (codeBundleId is RN only, so ommitted)
    And the payload field "events.0.app.bundleVersion" is not null
    And the payload field "events.0.app.dsymUUIDs" is a non-empty array
    And the payload field "events.0.app.id" equals "com.bugsnag.iOSTestApp"
    And the payload field "events.0.app.releaseStage" equals "development"
    And the payload field "events.0.app.type" equals "iOS"
    And the payload field "events.0.app.version" equals "1.0.3"
    
    # AppWithState
    
    And the payload field "events.0.app.duration" is a number
    And the payload field "events.0.app.durationInForeground" is a number
    And the payload field "events.0.app.inForeground" is true
