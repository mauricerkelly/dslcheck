defmodule Dslcheck.Parser do

  def parse_body(body) do
    table_row = parse_table_row_from_body(body)
    connection_stats = parse_connection_stats_from_table_row(table_row)
    connection_stats
  end

  def parse_table_row_from_body(body) do
    Floki.find(body, "table")
    |> Enum.at(3)
    |> Floki.find("tr")
    |> Enum.at(2)
    |> Floki.find("td")
  end

  def parse_connection_stats_from_table_row(table_row) do
    downstream_high = extract_value_from_table_data(table_row, 1)
    downstream_low  = extract_value_from_table_data(table_row, 2)
    upstream_high   = extract_value_from_table_data(table_row, 3)
    upstream_low    = extract_value_from_table_data(table_row, 4)
    { downstream_high, downstream_low, upstream_high, upstream_low }
  end

  def extract_value_from_table_data(table_data, position) do
    table_data
    |> Enum.at(position)
    |> Floki.text
  end

end
