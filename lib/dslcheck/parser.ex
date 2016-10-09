defmodule Dslcheck.Parser do

  def parse_connection_data_from_body(body) do
    table_row = parse_table_row_from_body(body)

    case table_row do
      nil ->
        { "0", "0", "0", "0" }
      table_row ->
        parse_connection_stats_from_table_row(table_row)
    end
  end

  def parse_cabinet_number_from_body(body) do
    body
    |> Floki.find("span span span")
    |> Enum.at(0)
    |> children_from_fragment
    |> Enum.at(0)
    |> cabinet_number_from_address_line
  end

  def children_from_fragment(fragment) do
    { _, _, children_nodes } = fragment
    children_nodes
  end

  def cabinet_number_from_address_line(address_line) do
    { _, regex } = Regex.compile("Address (.*)\n on Exchange (\\w*)\n is served by Cabinet (\\d*)\n")
    Regex.run(regex, address_line)
    |> Enum.at(3)
  end

  def parse_table_row_from_body(body) do
    extract_all_table_rows_from_body(body)
    |> extract_table_row_by_name("VDSL Range A (Clean)")
  end

  def extract_all_table_rows_from_body(body) do
    Floki.find(body, "table")
    |> Enum.at(3)
    |> Floki.find("tr")
  end

  def extract_table_row_by_name([], _) do
    nil
  end

  def extract_table_row_by_name([first_row | table_rows], name) do
    cell_content = extract_value_from_table_row(first_row, 0)
    if cell_content == name do
      first_row
    else
      extract_table_row_by_name(table_rows, name)
    end
  end

  def extract_value_from_table_row(table_row, position) do
    table_data = Floki.find(table_row, "td")
    unless Enum.count(table_data) > 0 do
      ""
    else
      table_data
      |> Enum.at(position)
      |> Floki.text
    end
  end

  def parse_connection_stats_from_table_row(table_row) do
    downstream_high = extract_value_from_table_row(table_row, 1)
    downstream_low  = extract_value_from_table_row(table_row, 2)
    upstream_high   = extract_value_from_table_row(table_row, 3)
    upstream_low    = extract_value_from_table_row(table_row, 4)
    { downstream_high, downstream_low, upstream_high, upstream_low }
  end

end
