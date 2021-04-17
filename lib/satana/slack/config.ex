defmodule Satana.Slack.Config do
  @enforce_keys [:webhook_url]

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          webhook_url: String.t()
        }

  @spec new :: t()
  def new do
    key_value = Application.get_env(:satana, __MODULE__)
    webhook_url = Keyword.fetch!(key_value, :webhook_url)

    %__MODULE__{
      webhook_url: webhook_url
    }
  end
end
