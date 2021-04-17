defmodule Satana.Blocknative.Config do
  @enforce_keys [:api_key, :basic_auth]

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          api_key: String.t(),
          basic_auth: %{
            username: String.t(),
            password: String.t()
          }
        }

  @spec new :: t()
  def new do
    key_value = Application.get_env(:satana, __MODULE__)
    api_key = Keyword.fetch!(key_value, :api_key)
    basic_auth = Keyword.fetch!(key_value, :basic_auth)

    %__MODULE__{
      api_key: api_key,
      basic_auth: Map.new(basic_auth)
    }
  end
end
