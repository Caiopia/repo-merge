When("I run {string}") do |event_type|
  steps %Q{
    Given the element "ScenarioNameField" is present
    When I send the keys "#{event_type}" to the element "ScenarioNameField"
    And I close the keyboard
    And I click the element "StartScenarioButton"
  }
end

When("I set the app to {string} mode") do |mode|
  steps %Q{
    Given the element "ScenarioMetaDataField" is present
    When I send the keys "#{mode}" to the element "ScenarioMetaDataField"
    And I close the keyboard
  }
end

When("I run {string} and relaunch the app") do |event_type|
  steps %Q{
    When I run "#{event_type}"
    And I relaunch the app
  }
end

When("I clear all UserDefaults data") do
  steps %Q{
    Given the element "ClearUserDefaultsButton" is present
    And I click the element "ClearUserDefaultsButton"
  }
end

When("I close the keyboard") do
  steps %Q{
    Given the element "CloseKeyboardItem" is present
    And I click the element "CloseKeyboardItem"
  }
end

When("I configure Bugsnag for {string}") do |event_type|
  steps %Q{
    Given the element "ScenarioNameField" is present
    When I send the keys "#{event_type}" to the element "ScenarioNameField"
    And I close the keyboard
    And I click the element "StartBugsnagButton"
  }
end

When("I send the app to the background") do
  $driver.background_app(-1)
end

When("I relaunch the app") do
  $driver.launch_app
end

When("I clear the request queue") do
  Server.stored_requests.clear
end

When("derp {string}") do |value|
  send_keys_to_element("ScenarioNameField", value)
end

# 0: The current application state cannot be determined/is unknown
# 1: The application is not running
# 2: The application is running in the background and is suspended
# 3: The application is running in the background and is not suspended
# 4: The application is running in the foreground
Then("The app is running in the foreground") do
  wait_for_true do
    status = $driver.execute_script('mobile: queryAppState',{bundleId: "com.bugsnag.iOSTestApp"})
    status == 4
  end
end

Then("The app is running in the background") do
  wait_for_true do
    status = $driver.execute_script('mobile: queryAppState',{bundleId: "com.bugsnag.iOSTestApp"})
    status == 3
  end
end

Then("The app is not running") do
  wait_for_true do
    status = $driver.execute_script('mobile: queryAppState',{bundleId: "com.bugsnag.iOSTestApp"})
    status == 1
  end
end

Then("the received requests match:") do |table|
  # Checks that each request matches one of the event fields
  requests = Server.stored_requests
  request_count = requests.count()
  match_count = 0

  # iterate through each row in the table. exactly 1 request should match each row.
  table.hashes.each do |row|
    requests.each do |request|
      event = read_key_path(request[:body], "events.0")
      match_count += 1 if request_matches_row(event, row)
    end
  end
  assert_equal(request_count, match_count, "Unexpected number of requests matched the received payloads")
end

def request_matches_row(body, row)
  row.all? do |key, expected_value|
    obs_val = read_key_path(body, key)
    match = false
    if "null".eql? expected_value && obs_val.nil?
      match = true
    elsif !obs_val.nil? && (expected_value.eql? obs_val.to_s)
      match = true
    end
    return false if !match
  end
  true
end

Then("the payload field {string} is equal for request {int} and request {int}") do |key, index_a, index_b|
  assert_true(request_fields_are_equal(key, index_a, index_b))
end

Then("the payload field {string} is not equal for request {int} and request {int}") do |key, index_a, index_b|
  assert_false(request_fields_are_equal(key, index_a, index_b))
end

def request_fields_are_equal(key, index_a, index_b)
  requests = Server.stored_requests.to_a
  assert_true(requests.length > index_a, "Not enough requests received to access index #{index_a}")
  assert_true(requests.length > index_b, "Not enough requests received to access index #{index_b}")
  request_a = requests[index_a][:body]
  request_b = requests[index_b][:body]
  val_a = read_key_path(request_a, key)
  val_b = read_key_path(request_b, key)
  return val_a.eql? val_b
end

Then("the event {string} is within {int} seconds of the current timestamp") do |field, threshold_secs|
  value = read_key_path(Server.current_request[:body], "events.0.#{field}")
  assert_not_nil(value, "Expected a timestamp")
  nowSecs = Time.now.to_i
  thenSecs = Time.parse(value).to_i
  delta = nowSecs - thenSecs
  assert_true(delta.abs < threshold_secs, "Expected current timestamp, but received #{value}")
end

Then("the event breadcrumbs contain {string} with type {string}") do |string, type|
  crumbs = read_key_path(find_request(0)[:body], "events.0.breadcrumbs")
  assert_not_equal(0, crumbs.length, "There are no breadcrumbs on this event")
  match = crumbs.detect do |crumb|
    crumb["name"] == string && crumb["type"] == type
  end
  assert_not_nil(match, "No crumb matches the provided message and type")
end

Then("the event breadcrumbs contain {string}") do |string|
  crumbs = read_key_path(Server.current_request[:body], "events.0.breadcrumbs")
  assert_not_equal(0, crumbs.length, "There are no breadcrumbs on this event")
  match = crumbs.detect do |crumb|
    crumb["name"] == string
  end
  assert_not_nil(match, "No crumb matches the provided message")
end

Then("the stack trace is an array with {int} stack frames") do |expected_length|
  stack_trace = read_key_path(Server.current_request[:body], "events.0.exceptions.0.stacktrace")
  assert_equal(expected_length,  stack_trace.length)
end

Then("the stacktrace contains methods:") do |table|
  stack_trace = read_key_path(Server.current_request[:body], "events.0.exceptions.0.stacktrace")
  expected = table.raw.flatten
  actual = stack_trace.map{|s| s["method"]}
  contains = actual.each_cons(expected.length).to_a.include? expected
  assert_true(contains, "Stacktrace methods #{actual} did not contain #{expected}")
end

Then("the payload field {string} matches the test device model") do |field|
  internal_names = {
    "iPhone 7" => ["iPhone9,1", "iPhone9,2", "iPhone9,3", "iPhone9,4"],
    "iPhone 8" => ["iPhone10,1", "iPhone10,2", "iPhone10,4", "iPhone10,5"],
    "iPhone X" => ["iPhone10,3", "iPhone10,6"],
    "iPhone XR" => ["iPhone11,8"],
    "iPhone XS" => ["iPhone11,2", "iPhone11,4", "iPhone11,8"]
  }
  expected_model = Devices::DEVICE_HASH[$driver.device_type]["device"]
  valid_models = internal_names[expected_model]
  device_model = read_key_path(Server.current_request[:body], field)
  assert_true(valid_models.include?(device_model), "The field #{device_model} did not match any of the list of expected fields")
end

def wait_for_true
  max_attempts = 300
  attempts = 0
  assertion_passed = false
  until (attempts >= max_attempts) || assertion_passed
    attempts += 1
    assertion_passed = yield
    sleep 0.1
  end
  raise "Assertion not passed in 30s" unless assertion_passed
end

def send_keys_to_element(element_id, text)
  element = find_element(@element_locator, element_id)
  element.clear()
  element.set_value(text)
end
