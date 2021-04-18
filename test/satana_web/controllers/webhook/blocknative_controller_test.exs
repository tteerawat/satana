defmodule SatanaWeb.Webhook.BlocknativeControllerTest do
  use SatanaWeb.ConnCase, async: true
  use Mimic

  alias Satana.ETHTransactions

  describe "POST /webhook/blocknative" do
    test "returns 401 if the request is not authorized", %{conn: conn} do
      reject(&ETHTransactions.confirm_transaction!/1)

      conn =
        conn
        |> put_req_header("authorization", Plug.BasicAuth.encode_basic_auth("invalid", "invalid"))
        |> post("/webhook/blocknative", %{"hash" => "0x123", "status" => "confirmed"})

      assert conn.status == 401
    end

    test "retrns 200 if the request is authorized and transaction can be confirmed", %{conn: conn} do
      expect(ETHTransactions, :confirm_transaction!, fn "0x123" -> :ok end)

      conn =
        conn
        |> put_req_header("authorization", Plug.BasicAuth.encode_basic_auth("test", "test"))
        |> post("/webhook/blocknative", %{"hash" => "0x123", "status" => "confirmed"})

      assert conn.status == 200
    end
  end
end
