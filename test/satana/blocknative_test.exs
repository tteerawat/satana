defmodule Satana.BlocknativeTest do
  use ExUnit.Case, async: true

  alias Satana.Blocknative

  setup do
    {:ok, bypass: Bypass.open()}
  end

  describe "add_eth_transaction_to_watch/2" do
    test "handles 200 status code", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/transaction", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"msg\":\"success\"}")
      end)

      tx_id = "0xc3417d9e15635cb2d863f6481e6eea8f3449cab82c9d9016e2c36628bf79a8ff"
      base_url = build_base_url(bypass.port)

      result = Blocknative.add_eth_transaction_to_watch(tx_id, base_url)

      assert result == :ok
    end

    test "handles 400 status code", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/transaction", fn conn ->
        Plug.Conn.resp(conn, 400, "{\"msg\":\"invalid hash\"}")
      end)

      tx_id = "0x123"
      base_url = build_base_url(bypass.port)

      result = Blocknative.add_eth_transaction_to_watch(tx_id, base_url)

      assert result == {:error, "invalid hash"}
    end

    test "handles error exception", %{bypass: bypass} do
      Bypass.down(bypass)

      tx_id = "0xc3417d9e15635cb2d863f6481e6eea8f3449cab82c9d9016e2c36628bf79a8ff"
      base_url = build_base_url(bypass.port)

      result = Blocknative.add_eth_transaction_to_watch(tx_id, base_url)

      assert result == {:error, "internal server error - connection refused"}
    end
  end

  defp build_base_url(port) do
    "http://localhost:#{port}"
  end
end
