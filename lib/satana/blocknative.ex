defmodule Satana.Blocknative do
  alias Satana.Blocknative.Config
  alias Satana.HTTPClient

  @base_url "https://api.blocknative.com"
  @eth_blockchain "ethereum"
  @network "main"

  @spec add_eth_transaction_to_watch(String.t(), String.t()) :: :ok | {:error, String.t()}
  def add_eth_transaction_to_watch(tx_id, base_url \\ @base_url) do
    url = base_url <> "/transaction"
    config = Config.new()

    body_params = %{
      apiKey: config.api_key,
      hash: tx_id,
      blockchain: @eth_blockchain,
      network: @network
    }

    case HTTPClient.json_request(:post, url, body_params: body_params) do
      {:ok, %HTTPClient.Response{status: 200}} ->
        :ok

      {:ok, %HTTPClient.Response{status: 400, body: %{msg: error_msg}}} ->
        {:error, error_msg}

      {:error, exception} ->
        {:error, "internal server error - #{Exception.message(exception)}"}
    end
  end
end
