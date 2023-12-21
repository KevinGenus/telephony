defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Pospaid, Prepaid, Subscriber}

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
end
