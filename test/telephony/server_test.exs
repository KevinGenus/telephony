defmodule Telephony.ServerTest do
  use ExUnit.Case

  alias Telephony.Server

  setup do
    {:ok, pid} = Server.start_link(:test)
    payload = %{full_name: "Kevin", type: :prepaid, phone_number: "123"}

    %{pid: pid, process_name: :test, payload: payload}
  end

  test "check telephony subscribers state", %{pid: pid} do
    assert [] == :sys.get_state(pid)
  end

  test "create a subscriber", %{pid: pid, process_name: process_name, payload: payload} do
    old_state = :sys.get_state(pid)
    assert [] == :sys.get_state(pid)

    result = GenServer.call(process_name, {:create_subscriber, payload})
    refute old_state == result
  end

  test "error message when creating existing subscriber", %{
    pid: pid,
    process_name: process_name,
    payload: payload
  } do
    old_state = :sys.get_state(pid)
    assert [] == old_state

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:create_subscriber, payload})
    assert {:error, "Subscriber `123` already exists"} == result
  end

  test "search for a subscriber", %{process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:search_subscriber, payload.phone_number})
    assert result.phone_number == payload.phone_number
  end

  test "make a recharge", %{pid: pid, process_name: process_name, payload: payload} do
    GenServer.call(process_name, {:create_subscriber, payload})

    date = Date.utc_today()
    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    assert subscriber_state.type.recharges == []
    :ok = GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})

    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    refute subscriber_state.type.recharges == []
  end

  test "make a successful call", %{pid: pid, process_name: process_name, payload: payload} do
    date = Date.utc_today()
    phone_number = payload.phone_number
    time_spent = 10

    GenServer.call(process_name, {:create_subscriber, payload})
    GenServer.cast(process_name, {:make_recharge, phone_number, 100, date})

    state = :sys.get_state(pid)
    subscriber_state = hd(state)
    assert subscriber_state.calls == []

    result = GenServer.call(process_name, {:make_call, phone_number, time_spent, date})

    assert result.calls == [%Telephony.Core.Call{time_spent: 10, date: date}]
  end

  test "make an error call", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    phone_number = payload.phone_number
    time_spent = 10

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:make_call, phone_number, time_spent, date})

    assert result == {:error, "Subscriber does not have credits"}
  end

  test "print an invoice", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    phone_number = payload.phone_number

    GenServer.call(process_name, {:create_subscriber, payload})
    result = GenServer.call(process_name, {:print_invoice, phone_number, date.year, date.month})

    assert result.invoice.calls == []
  end

  test "print invoices", %{process_name: process_name, payload: payload} do
    date = Date.utc_today()
    payload_2 = %{full_name: "", type: :prepaid, phone_number: "1234"}
    time_spent = 10

    GenServer.call(process_name, {:create_subscriber, payload})
    GenServer.call(process_name, {:create_subscriber, payload_2})
    GenServer.cast(process_name, {:make_recharge, payload.phone_number, 100, date})
    GenServer.cast(process_name, {:make_recharge, payload_2.phone_number, 50, date})
    GenServer.call(process_name, {:make_call, payload.phone_number, time_spent, date})
    GenServer.call(process_name, {:make_call, payload.phone_number, time_spent + 20, date})
    GenServer.call(process_name, {:make_call, payload.phone_number, time_spent + 3, date})

    GenServer.call(
      process_name,
      {:make_call, payload_2.phone_number, time_spent + 7, date}
    )

    GenServer.call(process_name, {:make_call, payload_2.phone_number, time_spent, date})
    [first, last] = GenServer.call(process_name, {:print_invoices, date.year, date.month})

    assert first.invoice.calls == [
             %{date: date, time_spent: 10, value_spent: 14.5},
             %{date: date, time_spent: 30, value_spent: 43.5},
             %{date: date, time_spent: 13, value_spent: 18.849999999999998}
           ]

    assert last.invoice.calls == [
             # assert result |> tl() |> then(& &1.invoice.calls) == [
             %{date: date, time_spent: 17, value_spent: 24.65},
             %{date: date, time_spent: 10, value_spent: 14.5}
           ]
  end
end
