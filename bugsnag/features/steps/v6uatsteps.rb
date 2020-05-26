require 'date'

# Number

Then(/^the payload field "(.+)" is a number$/) do |field_path|
    value = read_key_path(Server.current_request[:body], field_path)
    assert_kind_of Numeric, value
end

# Float

Then(/^the payload field "(.+)" is a float$/) do |field_path|
    value = read_key_path(find_request(request_index)[:body], field_path)
    assert_true(value.is_a?(Float))
end

# Integer

Then(/^the payload field "(.+)" is an integer$/) do |field_path|
    value = read_key_path(Server.current_request[:body], field_path)
    assert_true(value.is_a?(Integer))
end

# Date

Then(/^the payload field "(.+)" is a date$/) do |field_path|
    value = read_key_path(Server.current_request[:body], field_path)
    date = Date.parse(value) rescue nil
    assert_true(date.is_a?(Date))
end