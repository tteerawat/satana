defmodule Satana.Slack do
  alias Satana.HTTPClient
  alias Satana.Slack.Config

  require Logger

  @spec send_message(String.t(), String.t() | nil) :: :ok | :error
  def send_message(text, webhook_url \\ nil) do
    url = webhook_url || Config.new().webhook_url
    body_params = %{text: text}

    case HTTPClient.json_request(:post, url, body_params: body_params) do
      {:ok, %HTTPClient.Response{status: 200}} ->
        :ok

      error ->
        Logger.error(fn -> "Unable to send Slack message - #{inspect(error)}" end)

        :error
    end
  end
end
