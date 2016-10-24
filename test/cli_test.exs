defmodule CliTest do
  use ExUnit.Case
  doctest Dslcheck

  import Dslcheck.CLI, only: [ parse_args: 1 ]
  test ":help returned by option parsing with -h and --help options" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "two values returned if --housenumber and --postcode given" do
    assert parse_args(["--housenumber", "97", "--postcode", "BT25 2AL"]) == %{ housenumber: "97", postcode: "BT25 2AL" }
  end




end
