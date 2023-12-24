defmodule Telephony.Core.PospaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Invoice, Pospaid, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0},
      calls: []
    }

    price_per_minute = 1.04

    %{subscriber: subscriber, price_per_minute: price_per_minute}
  end

  test "make a call", %{subscriber: subscriber, price_per_minute: price_per_minute} do
    time_spent = 2
    spent = time_spent * price_per_minute
    date = NaiveDateTime.utc_now()
    result = Pospaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: spent},
      calls: [%Call{time_spent: time_spent, date: date}]
    }

    assert result == expect
  end

  test "print invoice", %{price_per_minute: price_per_minute} do
    dec_date = ~D[2023-12-23]
    nov_date = ~D[2023-11-23]

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Pospaid{
        spent: 90 * price_per_minute
      },
      calls: [
        %Call{time_spent: 10, date: dec_date},
        %Call{time_spent: 50, date: nov_date},
        %Call{time_spent: 30, date: nov_date}
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    expect = %{
      value_spent: 80 * price_per_minute,
      calls: [
        %{time_spent: 50, value_spent: 50 * price_per_minute, date: nov_date},
        %{time_spent: 30, value_spent: 30 * price_per_minute, date: nov_date}
      ]
    }

    assert expect == Invoice.print(subscriber_type, calls, 2023, 11)
  end
end
