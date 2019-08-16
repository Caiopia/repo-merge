require 'shellwords'

def find_symbol_file(filepath, uuid)
  if filepath.end_with? '.dylib'
    # FUTURE(dm): Use the correct version number for actual devices
    # Something like: 
    #   sdk_path = `xcrun --show-sdk-path -sdk iphoneos#{MAZE_SDK}`.chomp
    #   symbol_path = File.join(sdk_path, filepath)
    # For simulators, the dylib path is root.
    filepath
  else
    # Locate file.app.dSYM or Bugsnag.dSYM 
    # Exclude log files, which might include the UUID and confuse mdfind
    symbol_path = `mdfind #{uuid}`.split("\n").detect { |f| f.end_with? '.dSYM' }
    Dir.glob("#{symbol_path}/Contents/Resources/DWARF/*").first
  end
end

def symbolicate(frame)
  puts "Frame: #{frame}"
  assert_not_nil(frame)
  assert_not_nil(frame['machoUUID'], 'No machoUUID present in frame')
  assert_not_nil(frame['frameAddress'], 'No frameAddress present in frame')
  assert_not_nil(frame['symbolAddress'], 'No symbolAddress present in frame')
  assert_not_nil(frame['machoLoadAddress'], 'No machoLoadAddress present in frame')
  assert_not_nil(frame['machoVMAddress'], 'No machoVMAddress present in frame')
  assert_not_nil(frame['machoFile'], 'No machoFile present in frame')

  symbol_path = find_symbol_file(frame['machoFile'], frame['machoUUID'])
  puts "Symbol path: #{symbol_path}\n"
  assert_not_nil(symbol_path, "No symbol file found for frame: #{frame}")

  # FUTURE(dm): we could validate the other fields here, like machoVMAddress, to
  # check that everything lines up. This currently checks machoFile, machoUUID,
  # frameAddress, and machoLoadAddress.
  `atos -o #{Shellwords.escape(symbol_path)} -arch x86_64 -l #{frame["machoLoadAddress"]} #{frame["frameAddress"]}`.chomp
end

Then('the symbolicated stacktrace matches:') do |table|
  step('the symbolicated stacktrace in request 0 matches:', table)
end

Then('the symbolicated stacktrace in request {int} matches:') do |request_index, table|
  stacktrace = read_key_path(find_request(request_index)[:body], "events.0.exceptions.0.stacktrace")
  table.raw.each_with_index do |row, index|
    # Slightly flexible to avoid requiring the slide amount for system frames
    result = symbolicate(stacktrace[index])
    expected = row[0]
    assert(result.start_with?(expected), 
           "The frame did not symbolicate to contain '#{expected}'. Result: #{result}")
  end
end
