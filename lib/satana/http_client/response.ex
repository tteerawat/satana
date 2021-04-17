defmodule Satana.HTTPClient.Response do
  defstruct [:status, :body]

  @type t :: %__MODULE__{
          status: non_neg_integer(),
          body: term()
        }

  @spec new(non_neg_integer(), term()) :: t()
  def new(status, body) do
    %__MODULE__{status: status, body: body}
  end
end
