defmodule Satana.ETHTransactions do
  alias Satana.Blocknative
  alias Satana.ETHTransactions.Store
  alias Satana.ETHTransactions.Transaction
  alias Satana.Slack

  require Logger

  @spec list_transactions_by_status(String.t()) :: [Transaction.t()]
  def list_transactions_by_status(status) do
    Store.list_transactions()
    |> Enum.filter(&(&1.status == status))
  end

  @spec add_eth_transaction(String.t()) :: :ok | {:error, String.t()}
  def add_eth_transaction(tx_id) do
    with :ok <- Store.add_transaction(tx_id, handle_transaction_in: {2, :minutes}, with: &handle_transaction/1),
         :ok <- Blocknative.add_eth_transaction_to_watch(tx_id) do
      text = "Transaction `#{tx_id}` has been registered :sunglasses:"
      Slack.send_message(text)

      :ok
    else
      {:error, :already_exists} ->
        {:error, "transaction #{tx_id} already exists"}

      {:error, msg} ->
        Logger.warn(fn -> "Rollback transaction #{tx_id} - #{msg}" end)

        Store.delete_transaction(tx_id)

        {:error, msg}
    end
  end

  defp handle_transaction(%Transaction{} = transaction) do
    if Transaction.pending?(transaction) do
      text = "It's been a while but transaction `#{transaction.tx_id}` is still pending :thinking_face:"
      Slack.send_message(text)
    end
  end

  @spec confirm_transaction!(String.t()) :: :ok
  def confirm_transaction!(tx_id) do
    :ok = Store.update_transaction(tx_id, &Transaction.confirm/1)

    text = "Transaction `#{tx_id}` has been confirmed :tada:"
    Slack.send_message(text)

    :ok
  end
end
