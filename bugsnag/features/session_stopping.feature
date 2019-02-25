Feature: Stopping and resuming sessions

Scenario: When a session is stopped the error has no session information
    When I run "StoppedSessionScenario"
    Then I should receive 2 requests
    And the request 0 is valid for the session tracking API
    And the request 1 is valid for the error reporting API
    And the payload field "events.0.session" is not null for request 1
    And the payload field "events.1.session" is null for request 1

Scenario: When a session is resumed the error uses the previous session information
    When I run "ResumedSessionScenario"
    Then I should receive 2 requests
    And the request 0 is valid for the session tracking API
    And the request 1 is valid for the error reporting API
    And the payload field "events.0.session.events.handled" equals 1 for request 1
    And the payload field "events.1.session.events.handled" equals 2 for request 1
    And the payload field "events.1.session.id" of request 1 equals the payload field "events.0.session.id" of request 1
    And the payload field "events.1.session.startedAt" of request 1 equals the payload field "events.0.session.startedAt" of request 1

Scenario: When a new session is started the error uses different session information
    When I run "NewSessionScenario"
    Then I should receive 3 requests
    And the request 0 is valid for the session tracking API
    And the request 1 is valid for the session tracking API
    And the request 2 is valid for the error reporting API
    And the payload field "events.0.session.events.handled" equals 1 for request 2
    And the payload field "events.1.session.events.handled" equals 1 for request 2
    And the payload field "events.0.session.id" of request 2 does not equal the payload field "events.1.session.id" of request 2
