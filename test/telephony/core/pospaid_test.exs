defmodule Telephony.Core.PospaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Pospaid}

  setup do
    %{pospaid: %Pospaid{spent: 0}, price_per_minute: 1.04}
  end

  test "make a call", %{pospaid: pospaid, price_per_minute: price_per_minute} do
    time_spent = 2
    spent = time_spent * price_per_minute
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(pospaid, time_spent, date)

    expect = {
      %Pospaid{spent: spent},
      %Call{time_spent: time_spent, date: date}
    }

    assert result == expect
  end

  test "print invoice", %{price_per_minute: price_per_minute} do
    dec_date = ~D[2023-12-23]
    nov_date = ~D[2023-11-23]

    pospaid = %Pospaid{spent: 90 * price_per_minute }
    calls = [
      %Call{time_spent: 10, date: dec_date},
      %Call{time_spent: 50, date: nov_date},
      %Call{time_spent: 30, date: nov_date}
    ]

    expect = %{
      value_spent: 80 * price_per_minute,
      calls: [
        %{time_spent: 50, value_spent: 50 * price_per_minute, date: nov_date},
        %{time_spent: 30, value_spent: 30 * price_per_minute, date: nov_date}
      ]
    }

    assert expect == Subscriber.print_invoice(pospaid, calls, 2023, 11)
  end
end
