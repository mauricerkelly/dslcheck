defmodule Dslcheck.Parser.Address do
  def parse_addresses_from_body(body) do
    [ _ | addresses ] = (body |> Floki.find("option"))
    addresses
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
    house_number = Enum.at(components, 2)
    road_address = Enum.at(components, 3)
    post_code = Enum.at(components, 6)
    urpn = List.last(components)

    { "#{house_number} #{road_address}, #{post_code}", urpn}
  end

end
