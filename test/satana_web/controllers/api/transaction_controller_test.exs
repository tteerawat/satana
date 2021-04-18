defmodule SatanaWeb.API.TransactionControllerTest do
  use SatanaWeb.ConnCase, async: true
  use Mimic

  alias Satana.ETHTransactions
  alias Satana.ETHTransactions.Transaction

  describe "GET /api/transactions/:status" do
    test "returns a list of transactions", %{conn: conn} do
      expect(ETHTransactions, :list_transactions_by_status, fn "pending" ->
        [
          %Transaction{tx_id: "0x123", status: "pending"},
          %Transaction{tx_id: "0x456", status: "pending"}
        ]
      end)

      conn = get(conn, "/api/transactions/pending")

      assert json_response(conn, 200) == %{
               "transactions" => [
                 %{"status" => "pending", "tx_id" => "0x123"},
                 %{"status" => "pending", "tx_id" => "0x456"}
               ]
             }
    end
  end

  describe "POST api/transactions" do
    test "returns a list of results if the given params is valid", %{conn: conn} do
      ETHTransactions
      |> expect(:add_eth_transaction, fn "0x123" -> :ok end)
      |> expect(:add_eth_transaction, fn "0x456" -> {:error, "invalid hash"} end)

      conn = post(conn, "/api/transactions", %{"tx_ids" => ["0x123", "0x456"]})

      assert json_response(conn, 200) == %{
               "results" => [
                 %{"tx_id" => "0x123", "error_message" => nil, "success" => true},
                 %{"tx_id" => "0x456", "error_message" => "invalid hash", "success" => false}
               ]
             }
    end

    test "returns error response if the given params is invalid", %{conn: conn} do
      reject(&ETHTransactions.add_eth_transaction/1)

      conn = post(conn, "/api/transactions", %{})

      assert json_response(conn, 400) == %{"message" => "invalid params"}
    end
  end
end
