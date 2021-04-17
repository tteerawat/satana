defmodule Satana.ETHTransactions.Store do
  use GenServer

  alias Satana.ETHTransactions.Transaction

  require Logger

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec add_transaction(String.t(), keyword()) :: :ok | {:error, :already_exists}
  def add_transaction(tx_id, handle_transaction_in: {num, unit}, with: callback_function)
      when unit in [:seconds, :minutes] and is_function(callback_function, 1) do
    GenServer.call(__MODULE__, {:add_new_transaction, tx_id, {num, unit}, callback_function})
  end

  @spec delete_transaction(String.t()) :: :ok
  def delete_transaction(tx_id) do
    GenServer.call(__MODULE__, {:delete_transaction, tx_id})
  end

  @spec update_transaction(String.t(), fun()) :: :ok | {:error, :not_found}
  def update_transaction(tx_id, update_function) when is_function(update_function, 1) do
    GenServer.call(__MODULE__, {:update_transaction, tx_id, update_function})
  end

  @spec list_transactions :: [Transaction.t()]
  def list_transactions do
    GenServer.call(__MODULE__, :list_transactions)
  end

  ## GenServer callbacks

  @impl GenServer
  def init(opts) do
    Logger.info(fn -> "Running #{__MODULE__}" end)
    initial_state = opts[:initial_state] || []
    {:ok, initial_state}
  end

  @impl GenServer
  def handle_call({:add_new_transaction, tx_id, {num, unit}, callback_function}, _from, current_transactions) do
    if Enum.find(current_transactions, &(&1.tx_id == tx_id)) do
      {:reply, {:error, :already_exists}, current_transactions}
    else
      time = apply(:timer, unit, [num])
      Process.send_after(self(), {:check_transaction_status, tx_id, callback_function}, time)
      new_transaction = Transaction.new(tx_id)

      {:reply, :ok, [new_transaction | current_transactions]}
    end
  end

  @impl GenServer
  def handle_call({:delete_transaction, tx_id}, _from, current_transactions) do
    index = Enum.find_index(current_transactions, &(&1.tx_id == tx_id))

    if index do
      updated_transactions = List.delete_at(current_transactions, index)

      {:reply, :ok, updated_transactions}
    else
      {:reply, :ok, current_transactions}
    end
  end

  @impl GenServer
  def handle_call({:update_transaction, tx_id, update_function}, _from, current_transactions) do
    index = Enum.find_index(current_transactions, &(&1.tx_id == tx_id))

    if index do
      updated_transactions = List.update_at(current_transactions, index, update_function)

      {:reply, :ok, updated_transactions}
    else
      {:reply, {:error, :not_found}, current_transactions}
    end
  end

  @impl GenServer
  def handle_call(:list_transactions, _from, transactions) do
    {:reply, transactions, transactions}
  end

  @impl GenServer
  def handle_info({:check_transaction_status, tx_id, callback_function}, transactions) do
    transaction = Enum.find(transactions, &(&1.tx_id == tx_id))

    if transaction, do: callback_function.(transaction)

    {:noreply, transactions}
  end
end
