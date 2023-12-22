defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Pospaid, Prepaid, Recharge, Subscriber}

  setup do
    pospaid = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 10, recharges: []}
    }

    %{pospaid: pospaid, prepaid: prepaid}
  end

  test "create a prepaid subscriber" do
    payload = %{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a pospaid subscriber" do
    payload = %{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: :pospaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: %Pospaid{spent: 0}
    }

    assert expect == result
  end

  test "make a pospaid call", %{pospaid: pospaid} do
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(pospaid, 2, date)

    expect = %Subscriber{
      phone_number: "123",
      full_name: "Kevin",
      subscriber_type: %Pospaid{spent: 2.08},
      calls: [%Call{time_spent: 2, date: date}]
    }

    assert expect == result
  end

  test "make a prepaid call", %{prepaid: prepaid} do
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_call(prepaid, 2, date)

    expect = %Subscriber{
      phone_number: "123",
      full_name: "Kevin",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
      calls: [%Call{time_spent: 2, date: date}]
    }

    assert expect == result
  end

  test "make a recharge", %{prepaid: prepaid} do
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_recharge(prepaid, 2, date)

    expect = %Subscriber{
      phone_number: "123",
      full_name: "Kevin",
      subscriber_type: %Prepaid{
        credits: 12,
        recharges: [
          %Recharge{value: 2, date: date}
        ]
      },
      calls: []
    }

    assert expect == result
  end

  test "throw error when recharge is not prepaid", %{pospaid: pospaid} do
    date = NaiveDateTime.utc_now()
    result = Subscriber.make_recharge(pospaid, 2, date)

    expect = {:error, "Only prepaid can make a recharge"}

    assert expect == result
  end
end
