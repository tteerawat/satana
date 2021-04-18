defmodule Satana.ETHTransactions.StoreTest do
  use ExUnit.Case

  alias Satana.ETHTransactions.Store
  alias Satana.ETHTransactions.Transaction

  setup do
    start_supervised!(Store)

    :ok
  end

  test "behaves as expected" do
    {:ok, agent_pid} = Agent.start_link(fn -> [] end)

    tx_id1 = "0x1ded29a6bc74abbcc51313fc261b2f97c7f1fc5b9adbbdbaca00ac959f519e7b"
    tx_id2 = "0xeb84a81a973187ff9d79934723eb801c400ed941a2a34215ddb202db152e4b84"
    tx_id3 = "0x58c9efa287cedee606bfe264898fc24b22ca4e824883585962d1d0ad1140dfd4"

    callback_function = fn %Transaction{} = transaction ->
      if Transaction.pending?(transaction) do
        Agent.update(agent_pid, fn state -> [transaction.tx_id | state] end)
      end
    end

    # check initial state
    assert Store.list_transactions() == []

    # add some transactions
    assert Store.add_transaction(tx_id1,
             handle_transaction_in: {2, :seconds},
             with: callback_function
           ) == :ok

    assert Store.add_transaction(tx_id2,
             handle_transaction_in: {2, :seconds},
             with: callback_function
           ) == :ok

    assert Store.add_transaction(tx_id3,
             handle_transaction_in: {2, :seconds},
             with: callback_function
           ) == :ok

    assert Store.add_transaction(tx_id1,
             handle_transaction_in: {2, :seconds},
             with: callback_function
           ) == {:error, :already_exists}

    # check state immediately after transactions added
    assert Store.list_transactions() == [
             %Transaction{
               tx_id: tx_id3,
               status: "pending"
             },
             %Transaction{
               tx_id: tx_id2,
               status: "pending"
             },
             %Transaction{
               tx_id: tx_id1,
               status: "pending"
             }
           ]

    # modify state
    assert Store.update_transaction(tx_id1, &Transaction.confirm/1) == :ok
    assert Store.update_transaction("0x123", &Transaction.confirm/1) == {:error, :not_found}
    assert Store.delete_transaction(tx_id3) == :ok

    # wait for callback function to be called
    :timer.sleep(2_500)

    # check current state after state modification
    assert Store.list_transactions() == [
             %Transaction{
               tx_id: tx_id2,
               status: "pending"
             },
             %Transaction{
               tx_id: tx_id1,
               status: "confirmed"
             }
           ]

    # check if callback function is called
    assert Agent.get(agent_pid, & &1) == [tx_id2]
  end
end
