defmodule AddressTest do
  use ExUnit.Case
  doctest Dslcheck

  import Dslcheck.Parser.Address

  @valid_address_data_1 "||123|BALLYNAHINCH RD|DROMARA|DROMORE|BT25 2AL|NI|A00003682123||185969666"
  @valid_address_data_2 "456|||BALLYNAHINCH RD|DROMARA|DROMORE|BT25 2AL|NI|A00003682123||185969666"
  @bad_address_data_1 "|||BALLYNAHINCH RD|DROMARA|DROMORE|BT25 2AL|NI|A00031642075||185969666"
  @bad_address_data_2 "||123|BALLYNAHINCH RD|DROMARA|DROMORE|BT25 2AL|NI|A00031642075||"

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

    assert address_data == @valid_address_data_1
  end

  test "the address components and urpn are extracted from the first address data string" do
    {success_atom, house_number, street_name, postcode, urpn} =
      extract_address_and_urpn_from_address_data(@valid_address_data_1)

    assert success_atom == :ok
    assert house_number == "123"
    assert street_name == "BALLYNAHINCH RD"
    assert postcode == "BT25 2AL"
    assert urpn == "185969666"
  end

  test "the address components and urpn are extracted from the second address data string" do
    {success_atom, house_number, street_name, postcode, urpn} =
      extract_address_and_urpn_from_address_data(@valid_address_data_2)

    assert success_atom == :ok
    assert house_number == "456"
    assert street_name == "BALLYNAHINCH RD"
    assert postcode == "BT25 2AL"
    assert urpn == "185969666"
  end

  describe "when the data is invalid" do
    test "the data is not extracted when there is no house number" do
      {failure_atom, raw_address} = extract_address_and_urpn_from_address_data(@bad_address_data_1)

      assert failure_atom == :error
      assert raw_address == @bad_address_data_1
    end

    test "the data is not extracted when there is no urpn" do
      {failure_atom, raw_address} = extract_address_and_urpn_from_address_data(@bad_address_data_2)

      assert failure_atom == :error
      assert raw_address == @bad_address_data_2
    end
  end

end
