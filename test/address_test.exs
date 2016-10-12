defmodule AddressTest do
  use ExUnit.Case
  doctest Dslcheck

  import Dslcheck.Parser.Address

  @address_data "||56A|BALLYNAHINCH RD|DROMARA|DROMORE|BT25 2AL|NI|A00003682123||185969666"

  test "options are extracted from the response body" do
    {:ok, response_body} = File.read("test/fixtures/postcode_fetch.html")
    extracted_options = Floki.parse(response_body) |>  extract_options_from_body

    assert Enum.count(extracted_options) == 23

    { tag, _, [content] } = Enum.at(extracted_options, 0)
    assert tag == "option"
    assert content == "BALLYNAHINCH RD, DROMARA, DROMORE, BT25 2AL"
  end

  test "the address data is extracted from a single option" do
    {:ok, options_fragment} = File.read("test/fixtures/fragments/address_options.html")
    second_option = Floki.parse(options_fragment) |> Enum.at(1)
    address_data = extract_address_data_from_option(second_option)

    assert address_data == @address_data
  end

  test "the address and urpn are extracted from the address data string" do
    {house_number, street_name, postcode, urpn} = extract_address_and_urpn_from_address_data(@address_data)

    assert house_number == "56A"
    assert street_name == "BALLYNAHINCH RD"
    assert postcode == "BT25 2AL"
    assert urpn == "185969666"
  end

end
