defmodule Telephony.Server do
  @moduledoc """
  Documentation for `Telephony.Server`.
  """
  @behaviour GenServer
  alias Telephony.Core

  @spec start_link(atom() | {:global, any()} | {:via, atom(), any()}) ::
          :ignore | {:error, any()} | {:ok, pid()}
  def start_link(server_name) do
    GenServer.start_link(__MODULE__, [], name: server_name)
  end

  def init(subscribers), do: {:ok, subscribers}

  def handle_call({:create_subscriber, payload}, _from, subscribers) do
    case Core.create_subscriber(subscribers, payload) do
      {:error, _} = err ->
        {:reply, err, subscribers}

      subscribers ->
        {:reply, subscribers, subscribers}
    end
  end

  def handle_call({:search_subscriber, phone_number}, _from, subscribers) do
    subscriber = Core.search_subscriber(subscribers, phone_number)
    {:reply, subscriber, subscribers}
  end

  def handle_cast({:make_recharge, phone_number, value, date}, subscribers) do
    case Core.make_recharge(subscribers, phone_number, value, date) do
      {:error, _} ->
        {:noreply, subscribers}

      {subscribers, _} ->
        {:noreply, subscribers}
    end
  end

  def handle_call({:make_call, phone_number, time_spent, date}, _from, subscribers) do
    case Core.make_call(subscribers, phone_number, time_spent, date) do
      {:error, _} = err ->
        {:reply, err, subscribers}

      {subscribers, subscriber} ->
        {:reply, subscriber, subscribers}
    end
  end

  def handle_call({:print_invoice, phone_number, year, month}, _from, subscribers) do
    invoice = Core.print_invoice(subscribers, phone_number, year, month)
    {:reply, invoice, subscribers}
  end

  def handle_call({:print_invoices, year, month}, _from, subscribers) do
    invoices = Core.print_invoices(subscribers, year, month)
    {:reply, invoices, subscribers}
  end
end
