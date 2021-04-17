defmodule Satana.SlackTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias Satana.Slack

  setup do
    {:ok, bypass: Bypass.open()}
  end

  describe "send_message/2" do
    test "handles 200 status code", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/", fn conn ->
        Plug.Conn.resp(conn, 200, "ok")
      end)

      text = "Hello world!"
      webhook_url = "http://localhost:#{bypass.port}"

      result = Slack.send_message(text, webhook_url)

      assert result == :ok
    end

    test "handles error", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/", fn conn ->
        Plug.Conn.resp(conn, 500, "boom")
      end)

      text = "Hello world!"
      webhook_url = "http://localhost:#{bypass.port}"

      assert capture_log(fn ->
               result = Slack.send_message(text, webhook_url)

               assert result == :error
             end) =~ "[error] Unable to send Slack message"
    end
  end
end
