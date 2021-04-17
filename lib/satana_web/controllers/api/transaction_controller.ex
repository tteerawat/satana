defmodule SatanaWeb.API.TransactionController do
  use SatanaWeb, :controller

  alias Satana.ETHTransactions

  @valid_statuses ~w(pending confirmed)

  def list_transactions(conn, %{"status" => status}) when status in @valid_statuses do
    transactions =
      status
      |> ETHTransactions.list_transactions_by_status()
      |> Enum.map(&Map.from_struct/1)

    conn
    |> put_status(:ok)
    |> json(%{transactions: transactions})
  end

  def add_transaction(conn, %{"tx_ids" => tx_ids}) when is_list(tx_ids) do
    results = Enum.map(tx_ids, &add_eth_transaction/1)

    conn
    |> put_status(:ok)
    |> json(%{results: results})
  end

  def add_transaction(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "invalid params"})
  end

  defp add_eth_transaction(tx_id) do
    case ETHTransactions.add_eth_transaction(tx_id) do
      :ok ->
        build_response(tx_id, true, nil)

      {:error, msg} ->
        build_response(tx_id, false, msg)
    end
  end

  defp build_response(tx_id, success, error_message) do
    %{
      tx_id: tx_id,
      success: success,
      error_message: error_message
    }
  end
end
