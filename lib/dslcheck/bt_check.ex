defmodule Dslcheck.BtCheck do
  @user_agent   [ {"User-agent", "Elixir dslcheck@chatswood.org.uk"} ]

  def fetch(house_number, postcode) do
    checker_url
    |> HTTPoison.post(checker_body(house_number, postcode), [], [recv_timeout: 10000])
    |> handle_response
  end

  def fetch_data_from_file(filename) do
    case File.read(filename) do
      { :ok, contents } -> contents
      _ -> ""
    end
  end

  defp checker_url do
    "http://dslchecker.bt.com/adsl/ADSLChecker.AddressOutput"
  end

  defp checker_body(house_number, postcode) do
    body = %{
      buildingnumber: house_number,
      buildingname: "",
      thoroughfare: "",
      posttown: "",
      PostCode: postcode,
      uprn: "",
      URL: "",
      SP_NAME: "a%20service%20provider",
      VERSION: "42",
      MS: "E",
      AEA: "Y",
      CAP: "no"
    }
    URI.encode_query(body)
  end

  defp handle_response ({ :ok, %{ status_code: 200, body: body } }) do
    { :ok, body }
  end

  defp handle_response ({ _, %{ status_code: _, body: body } }) do
    { :error, body }
  end
end
