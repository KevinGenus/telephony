defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Pospaid, Prepaid, Subscriber}

  setup do
    pospaid = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    prepaid = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    %{pospaid: pospaid, prepaid: prepaid}
  end

  test "create a prepaid subscriber" do
    payload = %{
      full_name: "Kevin",
      phone_number: "123",
      type: :prepaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert expect == result
  end

  test "create a pospaid subscriber" do
    payload = %{
      full_name: "Kevin",
      phone_number: "123",
      type: :pospaid
    }

    result = Subscriber.new(payload)

    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    assert expect == result
  end

  test "make a prepaid call" do
    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    date = ~D[2023-12-26]

    assert Subscriber.make_call(subscriber, 1, date) == %Subscriber{
             full_name: "Kevin",
             phone_number: "123",
             type: %Prepaid{credits: 8.55, recharges: []},
             calls: [%Call{time_spent: 1, date: date}]
           }
  end

  test "make a prepaid call without enough credits" do
    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    date = ~D[2023-12-26]

    assert Subscriber.make_call(subscriber, 1, date) ==
             {:error, "Subscriber does not have credits"}
  end

  test "make a pospaid call" do
    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    date = ~D[2023-12-26]

    assert Subscriber.make_call(subscriber, 1, date) == %Subscriber{
             full_name: "Kevin",
             phone_number: "123",
             type: %Pospaid{spent: 1.04},
             calls: [%Call{time_spent: 1, date: date}]
           }
  end
end
