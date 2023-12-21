defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Kevin",
        phone_number: "123",
        subscriber_type: :prepaid
      }
    ]

    payload = %{
      full_name: "Kevin",
      phone_number: "123",
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  test "create new subscriber", %{payload: payload} do
    subscribers = []
    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Kevin",
        phone_number: "123",
        subscriber_type: :prepaid
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Joe",
      phone_number: "1234",
      subscriber_type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        full_name: "Kevin",
        phone_number: "123",
        subscriber_type: :prepaid
      },
      %Subscriber{
        full_name: "Joe",
        phone_number: "1234",
        subscriber_type: :prepaid
      }
    ]

    assert expect == result
  end

  test "display error, when subscriber already exists", %{
    subscribers: subscribers, payload: payload
  } do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `123` already exists"} == result
  end

  test "display error, when subscriber_type does not exist ", %{payload: payload} do
    payload = Map.put(payload, :subscriber_type, :asdf)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'postpaid' are accepted"} == result
  end
end
