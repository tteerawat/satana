defmodule Satana.HTTPClient do
  alias Satana.HTTPClient.Response

  require Logger

  @json_content_type_header {"Content-Type", "application/json"}

  @spec json_request(atom(), String.t(), Keyword.t()) :: {:ok, Response.t()} | {:error, Mint.Types.error()}
  def json_request(method, url, opts \\ []) do
    headers = Keyword.get(opts, :headers, [])
    body_params = Keyword.get(opts, :body_params, nil)
    query_params = Keyword.get(opts, :query_params, %{})

    url_with_query_params = build_url(url, query_params)
    headers_with_content_type = [@json_content_type_header | headers]
    body = maybe_build_json_body(body_params)

    result =
      method
      |> Finch.build(url_with_query_params, headers_with_content_type, body)
      |> Finch.request(Satana.Finch)

    case result do
      {:ok, %Finch.Response{status: status} = response} ->
        Logger.debug(fn -> inspect(response) end)

        body =
          case Jason.decode(response.body, keys: :atoms) do
            {:ok, decoded} -> decoded
            {:error, _} -> response.body
          end

        {:ok, Response.new(status, body)}

      {:error, exception} ->
        Logger.error(fn -> inspect(exception) end)

        {:error, exception}
    end
  end

  defp build_url(url, query_params) do
    url
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(query_params))
    |> URI.to_string()
  end

  defp maybe_build_json_body(nil), do: nil
  defp maybe_build_json_body(%{} = body_params), do: Jason.encode!(body_params)
end
