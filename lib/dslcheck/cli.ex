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
    Dslcheck.BtCheck.fetch(house_number, postcode)
    |> parse_response(house_number)
    |> print_csv_connection_data
  end

  def parse_response({ :ok, body } = response, "") do
    addresses = Dslcheck.Parser.parse_addresses_from_body(body)
    Enum.map addresses, fn(address) ->
      parse_response(response, address)
    end
  end

  def parse_response({ :ok, body }, _) do
    connection_data = Dslcheck.Parser.parse_connection_data_from_body(body)
    cabinet_data = Dslcheck.Parser.parse_cabinet_number_from_body(body)
    {connection_data, cabinet_data}
  end

  def parse_response({ :error, error }) do
    IO.puts "Arse, something went wrong: #{error}"
    System.halt(1)
  end

  def print_verbose_connection_data({{ down_high, down_low, up_high, up_low}, cabinet}) do
    IO.puts("Downsteam high: #{down_high}\n" <>
            "Downsteam low:  #{down_low}\n" <>
            "Upsteam high:   #{up_high}\n" <>
            "Upsteam low:    #{up_low}\n" <>
            "Cabinet:        #{cabinet}")
  end

  def print_verbose_connection_data(nil) do
    IO.puts("Unable to get a result")
  end

  def print_csv_connection_data({{ down_high, down_low, up_high, up_low}, cabinet}) do
    IO.puts("#{down_high}," <> "#{down_low}," <> "#{up_high}," <> "#{up_low}," <> "#{cabinet}")
  end

end
