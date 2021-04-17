defmodule Satana.ETHTransactionsTest do
  use ExUnit.Case
  use Mimic

  import ExUnit.CaptureLog

  alias Satana.Blocknative
  alias Satana.ETHTransactions
  alias Satana.ETHTransactions.Store
  alias Satana.ETHTransactions.Transaction
  alias Satana.Slack

  @transactions [
    %Transaction{tx_id: "0x123", status: "pending"},
    %Transaction{tx_id: "0x456", status: "confirmed"}
  ]

  setup do
    start_supervised!({Store, initial_state: @transactions})

    :ok
  end

  describe "list_transactions_by_status/1" do
    test "returns a list of transactions from the given status" do
      assert ETHTransactions.list_transactions_by_status("pending") == [
               %Transaction{tx_id: "0x123", status: "pending"}
             ]

      assert ETHTransactions.list_transactions_by_status("confirmed") == [
               %Transaction{tx_id: "0x456", status: "confirmed"}
             ]

      assert ETHTransactions.list_transactions_by_status("new") == []
    end
  end

  describe "add_eth_transaction/1" do
    test "returns error if the given tx_id already exists" do
      reject(&Blocknative.add_eth_transaction_to_watch/1)

      result = ETHTransactions.add_eth_transaction("0x123")

      assert result == {:error, "transaction 0x123 already exists"}
    end

    test "returns error if there is an error from blocknative" do
      tx_id = "0x789"

      expect(Blocknative, :add_eth_transaction_to_watch, fn ^tx_id ->
        {:error, "this is error message from blocknative"}
      end)

      assert capture_log(fn ->
               result = ETHTransactions.add_eth_transaction(tx_id)

               assert result == {:error, "this is error message from blocknative"}
             end) =~ "[warn] Rollback transaction 0x789"
    end

    test "returns :ok and sends Slack message if there is no error" do
      tx_id = "0x789"

      expect(Blocknative, :add_eth_transaction_to_watch, fn ^tx_id ->
        :ok
      end)

      expect(Slack, :send_message, fn "Transaction `0x789` has been registered :sunglasses:" ->
        :ok
      end)

      result = ETHTransactions.add_eth_transaction(tx_id)

      assert result == :ok
    end
  end

  describe "confirm_transaction!/1" do
    test "raises an error if the given tx_id does not exists" do
      assert_raise MatchError, fn ->
        ETHTransactions.confirm_transaction!("0x789")
      end
    end

    test "returns :ok and sends Slack message if transaction can be confirmed" do
      expect(Slack, :send_message, fn "Transaction `0x123` has been confirmed :tada:" ->
        :ok
      end)

      result = ETHTransactions.confirm_transaction!("0x123")

      assert result == :ok
    end
  end
end
