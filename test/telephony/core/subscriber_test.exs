defmodule SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Pospaid, Prepaid, Recharge, Subscriber}

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
    date = ~D[2023-12-26]

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    assert Subscriber.make_call(subscriber, 1, date) ==
             %Subscriber{
               full_name: "Kevin",
               phone_number: "123",
               type: %Prepaid{credits: 8.55, recharges: []},
               calls: [%Call{time_spent: 1, date: date}]
             }
  end

  test "make a prepaid call without enough credits" do
    date = ~D[2023-12-26]

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert Subscriber.make_call(subscriber, 1, date) ==
             {:error, "Subscriber does not have credits"}
  end

  test "make a pospaid call" do
    date = ~D[2023-12-26]

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 0}
    }

    assert Subscriber.make_call(subscriber, 1, date) ==
             %Subscriber{
               full_name: "Kevin",
               phone_number: "123",
               type: %Pospaid{spent: 1.04},
               calls: [%Call{time_spent: 1, date: date}]
             }
  end

  test "make a recharge (prepaid call)" do
    date = ~D[2023-12-26]

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    assert Subscriber.make_recharge(subscriber, 100, date) ==
             %Subscriber{
               full_name: "Kevin",
               phone_number: "123",
               type: %Prepaid{
                 credits: 110,
                 recharges: [%Recharge{value: 100, date: date}]
               },
               calls: []
             }
  end

  test "make a recharge (pospaid call)" do
    date = ~D[2023-12-26]

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 1.04}
    }

    assert Subscriber.make_recharge(subscriber, 100, date) ==
             {:error, "Pospaid can not make a recharge"}
  end

  test "print invoice (pospaid call)" do
    date_nov = ~D[2023-11-26]
    date_dec = ~D[2023-12-26]

    subscriber = %Subscriber{
      calls: [
        %Call{time_spent: 20, date: date_nov},
        %Call{time_spent: 30, date: date_nov},
        %Call{time_spent: 10, date: date_dec}
      ],
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 10.40}
    }

    assert Subscriber.print_invoice(subscriber, 2023, 11) ==
             %{
               subscriber: %Telephony.Core.Subscriber{
                 full_name: "Kevin",
                 phone_number: "123",
                 type: %Telephony.Core.Pospaid{spent: 10.40},
                 calls: [
                   %Telephony.Core.Call{time_spent: 20, date: ~D[2023-11-26]},
                   %Telephony.Core.Call{time_spent: 30, date: ~D[2023-11-26]},
                   %Telephony.Core.Call{time_spent: 10, date: ~D[2023-12-26]}
                 ]
               },
               invoice: %{
                 calls: [
                   %{date: ~D[2023-11-26], time_spent: 20, value_spent: 20.8},
                   %{date: ~D[2023-11-26], time_spent: 30, value_spent: 31.200000000000003}
                 ],
                 value_spent: 52.0
               }
             }
  end

  test "print invoice (prepaid call)" do
    date_nov = ~D[2023-11-26]
    date_dec = ~D[2023-12-26]

    subscriber = %Subscriber{
      calls: [
        %Call{time_spent: 20, date: date_nov},
        %Call{time_spent: 30, date: date_nov},
        %Call{time_spent: 10, date: date_dec}
      ],
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    assert Subscriber.print_invoice(subscriber, 2023, 11) ==
             %{
               subscriber: %Telephony.Core.Subscriber{
                 full_name: "Kevin",
                 phone_number: "123",
                 type: %Telephony.Core.Prepaid{credits: 10, recharges: []},
                 calls: [
                   %Telephony.Core.Call{time_spent: 20, date: ~D[2023-11-26]},
                   %Telephony.Core.Call{time_spent: 30, date: ~D[2023-11-26]},
                   %Telephony.Core.Call{time_spent: 10, date: ~D[2023-12-26]}
                 ]
               },
               invoice: %{
                 recharges: [],
                 calls: [
                   %{date: ~D[2023-11-26], time_spent: 20, value_spent: 29.0},
                   %{date: ~D[2023-11-26], time_spent: 30, value_spent: 43.5}
                 ]
               }
             }
  end
end
