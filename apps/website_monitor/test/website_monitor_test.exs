defmodule WebsiteMonitorTest do
  use ExUnit.Case
  doctest WebsiteMonitor

  test "greets the world" do
    assert WebsiteMonitor.hello() == :world
  end
end
