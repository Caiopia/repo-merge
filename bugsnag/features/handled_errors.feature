Feature: Handled Errors and Exceptions

  Background:
    Given I clear all UserDefaults data

  Scenario: Override errorClass and message from a notifyError() callback, customize report

  Discard 2 lines from the stacktrace, as we have single place to report and log errors, see
  https://docs.bugsnag.com/platforms/ios-objc/reporting-handled-exceptions/#depth
  This way top of the stacktrace is not logError but run
  Include configured metadata dictionary into the report

    When I run "HandledErrorOverrideScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    And the exception "errorClass" equals "Bar"
    And the exception "message" equals "Foo"
    And the event "device.time" is within 30 seconds of the current timestamp
    And the event "metaData.account.items.0" equals 400
    And the event "metaData.account.items.1" equals 200
    And the event "severity" equals "warning"
    And the event "unhandled" is false
    And the event "severityReason.type" equals "handledError"
    # This may be platform specific.
    # TODO Consider using a step to check for "at least {int} stack frames"
    # And the stack trace is an array with 15 stack frames

  Scenario: Reporting an NSError
    When I run "HandledErrorScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    And the payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "NSError"
    And the exception "message" equals "The operation couldn’t be completed. (HandledErrorScenario error 100.)"
    And the event "severity" equals "warning"
    And the event "unhandled" is false
    And the event "severityReason.type" equals "handledError"
    # This may be platform specific
    # And the stack trace is an array with 15 stack frames

  Scenario: Reporting a handled exception
    When I run "HandledExceptionScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    And the payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "HandledExceptionScenario"
    And the exception "message" equals "Message: HandledExceptionScenario"
    And the event "severity" equals "warning"
    And the event "unhandled" is false
    And the event "severityReason.type" equals "handledException"
    # This may be platform specific
    # And the stack trace is an array with 15 stack frames

  Scenario: Reporting a handled exception's stacktrace
    When I run "NSExceptionShiftScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    And the payload field "events" is an array with 1 elements
    And the exception "errorClass" equals "Tertiary failure"
    And the exception "message" equals "invalid invariant"
    And the event "severity" equals "warning"
    And the event "unhandled" is false
    And the event "severityReason.type" equals "handledException"
    # This may be platform specific
    And the "method" of stack frame 0 equals "<redacted>"
    And the "method" of stack frame 1 equals "objc_exception_throw"
    And the "method" of stack frame 2 equals "-[NSExceptionShiftScenario causeAnException]"
    And the "method" of stack frame 3 equals "-[NSExceptionShiftScenario run]"

  Scenario: Reporting handled errors concurrently
    When I run "ManyConcurrentNotifyScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    And the payload field "events" is an array with 8 elements
    And each event in the payload matches one of:
      | exceptions.0.errorClass | exceptions.0.message |
      | FooError                | Err 0                |
      | FooError                | Err 1                |
      | FooError                | Err 2                |
      | FooError                | Err 3                |

  Scenario: Reporting handled errors concurrently in an environment without background thread reporting
    When I run "ManyConcurrentNotifyNoBackgroundThreads"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "iOS Bugsnag Notifier" notifier
    And the payload field "events" is an array with 8 elements
    And each event in the payload matches one of:
      | exceptions.0.errorClass | exceptions.0.message |
      | BarError                | Err 0                |
      | BarError                | Err 1                |
      | BarError                | Err 2                |
      | BarError                | Err 3                |
