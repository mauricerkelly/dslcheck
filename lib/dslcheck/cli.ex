defmodule Dslcheck.CLI do
  require(Logger)

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns :help.

  """
  def parse_args(argv) do
    Logger.debug("Parsing the command line options")
    parse = OptionParser.parse(argv, switches: [ help: :boolean, housenumber: :string, postcode: :string], aliases: [ h: :help ])
    case parse do
    { [ help: true ], _, _ }
      -> :help
    { [housenumber: housenumber, postcode: postcode], _, _ }
      -> %{ housenumber: housenumber, postcode: postcode }
    { [postcode: postcode], _, _}
      -> %{ postcode: postcode }
    _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
      usage: dslcheck --housenumber housenumber --postcode postcode
    """
    System.halt(0)
  end

  def process(%{housenumber: housenumber, postcode: postcode}) do
    Dslcheck.BtCheck.fetch(housenumber, postcode)
    |> parse_response(housenumber)
    |> print_csv_connection_data
  end

  def process(%{postcode: postcode}) do
    Logger.debug("Processing postcode only input: #{postcode}")
    Dslcheck.BtCheck.fetch("", postcode)
    |> parse_response("")
  end

  def parse_response({ :ok, body }, "") do
    addresses = Dslcheck.Parser.Address.parse_addresses_from_body(body)
    Enum.map addresses, fn(address) ->
      case address do
        {:ok, housenumber, street_name, postcode, _} ->
          process %{housenumber: housenumber, postcode: postcode}
        {:error, raw_address} -> nil
      end
    end
  end

  def parse_response({ :ok, body }, housenumber) do
    connection_data = Dslcheck.Parser.parse_connection_data_from_body(body)
    cabinet_data = Dslcheck.Parser.parse_cabinet_number_from_body(body)
    {housenumber, connection_data, cabinet_data}
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

  def print_csv_connection_data({housenumber, { down_high, down_low, up_high, up_low}, cabinet}) do
    IO.puts("#{housenumber}," <> "#{down_high}," <> "#{down_low}," <> "#{up_high}," <> "#{up_low}," <> "#{cabinet}")
  end

end
