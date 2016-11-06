defmodule ProperyTest do
  use ExUnit.Case

  test "Creating with all properties is successful" do
    property = %Dslcheck.Property{housenumber: "123", postcode: "BT12 3BT", uprn: "123456"}
    assert property.housenumber == "123"
    assert property.postcode == "BT12 3BT"
    assert property.uprn == "123456"
  end

  test "Creating with missing properties is successful" do
    property1 = %Dslcheck.Property{housenumber: "123"}
    assert property1.housenumber == "123"
    assert property1.postcode == nil
    assert property1.uprn == nil

    property2 = %Dslcheck.Property{postcode: "BT12 3BT"}
    assert property2.housenumber == nil
    assert property2.postcode == "BT12 3BT"
    assert property2.uprn == nil

    property3 = %Dslcheck.Property{uprn: "123456"}
    assert property3.housenumber == nil
    assert property3.postcode == nil
    assert property3.uprn == "123456"
  end
end
