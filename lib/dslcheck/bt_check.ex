defmodule Dslcheck.BtCheck do
  @user_agent   [ {"User-agent", "Elixir dslcheck@chatswood.org.uk"} ]

  def fetch(house_number, postcode) do
    checker_url
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp checker_url do
    "http://dslchecker.bt.com"
  end

  defp handle_response ({ :ok, %{ status_code: 200, body: body } }) do
    { :ok, body }
  end

  defp handle_response ({ _, %{ status_code: _, body: body } }) do
    { :error, body }
  end
end
