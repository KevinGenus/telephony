defmodule Telephony.Core.PospaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Pospaid, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0},
      calls: []
    }

    %{subscriber: subscriber}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Pospaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 2.08},
      calls: [%Call{time_spent: 2, date: date}]
    }

    assert result == expect
  end
end
