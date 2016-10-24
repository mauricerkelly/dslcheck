defmodule Dslcheck.Parser.Address do
  def parse_addresses_from_body(body) do
    body
    |> extract_options_from_body
    |> Enum.map(&do_parse_address_from_option/1)
  end
  
  def do_parse_address_from_option(option) do
    extract_address_data_from_option(option)
    |> extract_address_and_urpn_from_address_data
  end

  def extract_options_from_body(body) do
    [ _ | addresses ] = (body |> Floki.find("option"))
    addresses
  end

  def extract_address_data_from_option(option) do
    {_, tag_parameters, _} = option
    [{"value", address_data}] = tag_parameters
    address_data
  end

  def extract_address_and_urpn_from_address_data(address_data) do
    # ||56A|BALLYNAHINCH RD|DROMARA|DROMORE|BT25 2AL|NI|A00003682123||185969666
    components = String.split(address_data, "|")
    component_one = Enum.at(components, 0)
    component_three = Enum.at(components, 2)
    house_number = case {component_one, component_three} do
      {"", number} -> number
      {number, ""} -> number
    end
    street_address = Enum.at(components, 3)
    postcode = Enum.at(components, 6)
    urpn = List.last(components)

    case {house_number, urpn} do
      {"", _} -> {:error, address_data}
      {_, ""} -> {:error, address_data}
      {_, _} -> {:ok, house_number, street_address, postcode, urpn}
    end
  end

end
