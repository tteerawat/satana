defmodule SatanaWeb.Webhook.BlocknativeController do
  use SatanaWeb, :controller

  alias Satana.ETHTransactions

  require Logger

  plug :basic_auth

  def handle_webhook(conn, %{"hash" => tx_id, "status" => "confirmed"}) do
    :ok = ETHTransactions.confirm_transaction!(tx_id)

    conn
    |> put_status(:ok)
    |> json(%{})
  end

  def handle_webhook(conn, params) do
    Logger.info(fn -> inspect(params) end)

    conn
    |> put_status(:ok)
    |> json(%{})
  end

  defp basic_auth(conn, _opts) do
    config = Satana.Blocknative.Config.new()

    Plug.BasicAuth.basic_auth(
      conn,
      username: config.basic_auth.username,
      password: config.basic_auth.password
    )
  end
end
