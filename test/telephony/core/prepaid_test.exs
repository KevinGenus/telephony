defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Invoice, Prepaid, Recharge, Subscriber}

  setup do
    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    subscriber_without_credits = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    %{subscriber: subscriber, subscriber_without_credits: subscriber_without_credits}
  end

  test "make a call", %{subscriber: subscriber} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber, time_spent, date)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [
        %Call{
          time_spent: 2,
          date: date
        }
      ]
    }

    assert expect == result
  end

  test "try to make a call", %{subscriber_without_credits: subscriber_without_credits} do
    time_spent = 2
    date = NaiveDateTime.utc_now()
    result = Prepaid.make_call(subscriber_without_credits, time_spent, date)
    expect = {:error, "Subscriber does not have credits"}
    assert expect == result
  end

  test "make a recharge", %{subscriber: subscriber} do
    value = 100
    date = NaiveDateTime.utc_now()

    result = Prepaid.make_recharge(subscriber, value, date)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Prepaid{
        credits: 110,
        recharges: [%Recharge{value: 100, date: date}]
      },
      calls: []
    }

    assert expect == result
  end

  test "print invoice", %{subscriber: subscriber} do
    # date = NaiveDateTime.utc_now()
    dec_date = ~D[2023-12-23]
    nov_date = ~D[2023-11-23]
    # oct_date = ~D[2023-10-23]

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Prepaid{
        credits: 253.6,
        recharges: [
          %Recharge{value: 100, date: dec_date},
          %Recharge{value: 100, date: nov_date},
          %Recharge{value: 100, date: nov_date}
        ]
      },
      calls: [
        %Call{time_spent: 2, date: dec_date},
        %Call{time_spent: 10, date: nov_date},
        %Call{time_spent: 20, date: nov_date}
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls

    assert Invoice.print(subscriber_type, calls, 2023, 11) == %{
             calls: [
               %{time_spent: 10, value_spent: 14.5, date: nov_date},
               %{time_spent: 20, value_spent: 29.0, date: nov_date}
             ],
             recharges: [
               %Recharge{value: 100, date: nov_date},
               %Recharge{value: 100, date: nov_date}
             ]
           }
  end
end
