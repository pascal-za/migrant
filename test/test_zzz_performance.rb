require 'helper'

#SimpleProfiler.results

class TestZZZPerformance < Test::Unit::TestCase
  context "Performance" do
  should "be within acceptable limits" do
    # Just a utility test for printing profiler results
    Profiler.results
    assert true
  end
  end
end
