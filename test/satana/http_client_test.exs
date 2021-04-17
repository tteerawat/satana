defmodule Satana.HTTPClientTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Satana.HTTPClient

  setup do
    {:ok, bypass: Bypass.open()}
  end

  describe "json_request/3" do
    test "handles json response", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/todos/1", fn conn ->
        Plug.Conn.resp(conn, 200, "{\"comleted\":false,\"id\":1}")
      end)

      result = HTTPClient.json_request(:get, "http://localhost:#{bypass.port}/todos/1")

      assert result ==
               {:ok,
                %HTTPClient.Response{
                  status: 200,
                  body: %{id: 1, comleted: false}
                }}
    end

    test "handles not json response", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/todos", fn conn ->
        Plug.Conn.resp(conn, 200, "ok")
      end)

      result =
        HTTPClient.json_request(:post, "http://localhost:#{bypass.port}/todos", body_params: %{title: "do something"})

      assert result ==
               {:ok,
                %HTTPClient.Response{
                  status: 200,
                  body: "ok"
                }}
    end

    test "handles error exception", %{bypass: bypass} do
      Bypass.down(bypass)

      error_message =
        capture_log(fn ->
          result = HTTPClient.json_request(:get, "http://localhost:#{bypass.port}/todos/1")

          assert result == {:error, %Mint.TransportError{reason: :econnrefused}}
        end)

      assert error_message =~ "[error]"
    end
  end
end
