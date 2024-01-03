defmodule Telephony do
  @moduledoc """
  Documentation for `Telephony`.
  """

  @server :telephony

  def create_subscriber(payload) do
    GenServer.call(@server, {:create_subscriber, payload})
  end

  # def search_subscriber(phone_number) do
  # GenServer.call(@server, {:search_subscriber, phone_number})
  # end

  # def make_recharge(phone_number, value, date) do
  #   GenServer.cast(@server, {:make_recharge, phone_number, value, date})
  # end

  # def make_call(phone_number, time_spent, date) do
  #   GenServer.call(@server, {:make_call, phone_number, time_spent, date})
  # end

  # def print_invoice(phone_number, year, month) do
  #   GenServer.call(@server, {:make_call, phone_number, year, month})
  # end

  # def print_invoices(year, month) do
  #   GenServer.call(@server, {:make_call, year, month})
  # end
end
