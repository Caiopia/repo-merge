Feature: Enabled error types

  Background:
    Given I clear all persistent data

  Scenario: All Crash reporting is disabled
    # Sessions: on, unhandled crashes: off
    When I run "DisableAllExceptManualExceptionsAndCrashScenario" and relaunch the app
    And I configure Bugsnag for "DisableAllExceptManualExceptionsAndCrashScenario"
    # Give ignored report time to be processed
    And I wait for 2 seconds
    And I wait to receive 2 requests
    Then the request is valid for the session reporting API version "1.0" for the "iOS Bugsnag Notifier" notifier
    And I discard the oldest request
    Then the request is valid for the session reporting API version "1.0" for the "iOS Bugsnag Notifier" notifier

  Scenario: All Crash reporting is disabled but manual notification works
    # enabledErrorTypes = None, Generate a manual notification, crash
    When I run "DisableAllExceptManualExceptionsSendManualAndCrashScenario" and relaunch the app
    And I configure Bugsnag for "DisableAllExceptManualExceptionsSendManualAndCrashScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier

  Scenario: NSException Crash Reporting is disabled
    When I run "DisableNSExceptionScenario" and relaunch the app
    And I configure Bugsnag for "DisableNSExceptionScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    And the event "severity" equals "error"
    And the event "unhandled" is true
    And the event "severityReason.type" equals "signal"
    And the event "severityReason.attributes.signalType" equals "SIGABRT"

  Scenario: CPP Crash Reporting is disabled
    When I run "EnabledErrorTypesCxxScenario" and relaunch the app
    And I configure Bugsnag for "EnabledErrorTypesCxxScenario"
    # Give ignored SIGABRT report time to be processed
    And I wait for 2 seconds
    And I wait to receive 2 requests
    Then the request is valid for the session reporting API version "1.0" for the "iOS Bugsnag Notifier" notifier
    And I discard the oldest request
    Then the request is valid for the session reporting API version "1.0" for the "iOS Bugsnag Notifier" notifier

  Scenario: Mach Crash Reporting is disabled
    When I run "DisableMachExceptionScenario"
    And I relaunch the app
    And I configure Bugsnag for "DisableMachExceptionScenario"
    # Give ignored SIGSEGV report time to be processed
    And I wait for 2 seconds
    And I wait to receive 2 requests
    Then the request is valid for the session reporting API version "1.0" for the "iOS Bugsnag Notifier" notifier
    And I discard the oldest request
    Then the request is valid for the session reporting API version "1.0" for the "iOS Bugsnag Notifier" notifier

  Scenario: Signals Crash Reporting is disabled
    When I run "DisableSignalsExceptionScenario" and relaunch the app
    And I configure Bugsnag for "DisableSignalsExceptionScenario"
    And I wait for 5 seconds
    And I should receive no requests
