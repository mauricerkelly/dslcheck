defmodule Dslcheck.CLI do
  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """
  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean], aliases: [ h: :help ])
    case parse do
    { [ help: true ], _, _ }
      -> :help
    { _, [ house_number, postcode ], _ }
      -> { house_number, postcode }
    _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
      usage: dslcheck house_number postcode
    """
    System.halt(0)
  end

  def process({house_number, postcode}) do
    result = Dslcheck.BtCheck.fetch(house_number, postcode)
    |> parse_response

    print_connection_data(result)
  end

  def parse_response({ :ok, body }) do
    Dslcheck.Parser.parse_body(body)
  end

  def parse_response({ :error, error }) do
    IO.puts "Arse, something went wrong: #{error}"
    System.halt(1)
  end

  def print_connection_data({ down_high, down_low, up_high, up_low}) do
    IO.puts("Downsteam high: #{down_high}\nDownsteam low:  #{down_low}\nUpsteam high:   #{up_high}\nUpsteam low:    #{up_low}\n")
  end

end
