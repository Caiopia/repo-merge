Then("The exception reflects malloc corruption occurred") do
  # Two different outcomes can arise from this scenario, either:
  # * Write will fail on non-writable memory
  # * malloc fails in NSLog
  #
  # Depending on OS version, this changes the stacktrace contents
  body = find_request(0)[:body]
  exception = read_key_path(body, "events.0.exceptions.0")
  stacktrace = exception["stacktrace"]
  assert_true(stacktrace.length > 0, "The stacktrace must have more than 0 elements")

  case stacktrace.first["method"]
  when "__pthread_kill" # Any
    assert_equal("SIGABRT", exception["errorClass"])
    assert_equal("abort", stacktrace[1]["method"])
  when "nanov2_allocate_from_block" # iOS 12.1
    assert_equal("EXC_BAD_INSTRUCTION", exception["errorClass"])
    assert_equal("nanov2_allocate", stacktrace[1]["method"])
    assert_equal("NSLog", stacktrace[15]["method"])
    assert_equal("-[CorruptMallocScenario run]", stacktrace[16]["method"])
  when "notify_dump_status" # iOS 12.1
    assert_equal("EXC_BAD_ACCESS", exception["errorClass"])
    assert_equal("NSLog", stacktrace[10]["method"])
    assert_equal("-[CorruptMallocScenario run]", stacktrace[11]["method"])
  when "_nc_table_find_64" # iOS 11.2
    # We don't know whether the mach handler or the signal handler will catch this
    assert_true(["SIGSEGV", "EXC_BAD_ACCESS"].include?(exception["errorClass"]), "Error class was '#{exception["errorClass"]}'")
    assert_true(
      exception["message"] == "Attempted to dereference null pointer." ||
      exception["message"].start_with?("Attempted to dereference garbage pointer 0x"),
      "Message was '#{exception["message"]}'"
    )

    frame = 1

    if stacktrace[frame]["method"] == "registration_node_find"
      frame = 2
    end

    assert_equal("notify_check", stacktrace[frame]["method"])
    assert_equal("notify_check_tz", stacktrace[frame + 1]["method"])
    assert_equal("tzsetwall_basic", stacktrace[frame + 2]["method"])
    assert_equal("localtime_r", stacktrace[frame + 3]["method"])
    assert_equal("_populateBanner", stacktrace[frame + 4]["method"])
    assert_equal("_CFLogvEx2Predicate", stacktrace[frame + 5]["method"])
    assert_equal("_CFLogvEx3", stacktrace[frame + 6]["method"])
    assert_equal("_NSLogv", stacktrace[frame + 7]["method"])
    assert_equal("NSLog", stacktrace[frame + 8]["method"])
    assert_equal("-[CorruptMallocScenario run]", stacktrace[frame + 9]["method"])
  else
    fail("The exception does not reflect malloc corruption")
  end
end
