defmodule Satana.ETHTransactions.Transaction do
  @enforce_keys [:tx_id, :status]

  defstruct @enforce_keys

  @type t :: %__MODULE__{
          tx_id: String.t(),
          status: String.t()
        }

  @spec new(String.t()) :: t()
  def new(tx_id) do
    %__MODULE__{
      tx_id: tx_id,
      status: "pending"
    }
  end

  @spec confirm(t()) :: t()
  def confirm(%__MODULE__{} = transaction) do
    %{transaction | status: "confirmed"}
  end

  @spec pending?(t()) :: boolean()
  def pending?(%__MODULE__{status: status}) do
    status == "pending"
  end
end
