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
    date = Date.utc_today()

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
    date = Date.utc_today()

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    assert Subscriber.make_call(subscriber, 1, date) ==
             {:error, "Subscriber does not have credits"}
  end

  test "make a pospaid call" do
    date = Date.utc_today()

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
    date = Date.utc_today()

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
    date = Date.utc_today()

    subscriber = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 1.04}
    }

    assert Subscriber.make_recharge(subscriber, 100, date) ==
             {:error, "Pospaid can not make a recharge"}
  end

  test "print invoice (pospaid call)" do
    current_month = Date.beginning_of_month(Date.utc_today())
    previous_month = Date.beginning_of_month(Date.add(current_month, -1))
    year = previous_month.year
    month = previous_month.month

    subscriber = %Subscriber{
      calls: [
        %Call{time_spent: 20, date: previous_month},
        %Call{time_spent: 30, date: previous_month},
        %Call{time_spent: 10, date: current_month}
      ],
      full_name: "Kevin",
      phone_number: "123",
      type: %Pospaid{spent: 10.40}
    }

    assert Subscriber.print_invoice(subscriber, year, month) ==
             %{
               subscriber: %Telephony.Core.Subscriber{
                 full_name: "Kevin",
                 phone_number: "123",
                 type: %Telephony.Core.Pospaid{spent: 10.40},
                 calls: [
                   %Telephony.Core.Call{time_spent: 20, date: previous_month},
                   %Telephony.Core.Call{time_spent: 30, date: previous_month},
                   %Telephony.Core.Call{time_spent: 10, date: current_month}
                 ]
               },
               invoice: %{
                 calls: [
                   %{date: previous_month, time_spent: 20, value_spent: 20.8},
                   %{date: previous_month, time_spent: 30, value_spent: 31.200000000000003}
                 ],
                 value_spent: 52.0
               }
             }
  end

  test "print invoice (prepaid call)" do
    current_month = Date.beginning_of_month(Date.utc_today())
    previous_month = Date.beginning_of_month(Date.add(current_month, -1))
    year = previous_month.year
    month = previous_month.month

    subscriber = %Subscriber{
      calls: [
        %Call{time_spent: 20, date: previous_month},
        %Call{time_spent: 30, date: previous_month},
        %Call{time_spent: 10, date: current_month}
      ],
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 10, recharges: []}
    }

    assert Subscriber.print_invoice(subscriber, year, month) ==
             %{
               subscriber: %Telephony.Core.Subscriber{
                 full_name: "Kevin",
                 phone_number: "123",
                 type: %Telephony.Core.Prepaid{credits: 10, recharges: []},
                 calls: [
                   %Telephony.Core.Call{time_spent: 20, date: previous_month},
                   %Telephony.Core.Call{time_spent: 30, date: previous_month},
                   %Telephony.Core.Call{time_spent: 10, date: current_month}
                 ]
               },
               invoice: %{
                 recharges: [],
                 calls: [
                   %{date: previous_month, time_spent: 20, value_spent: 29.0},
                   %{date: previous_month, time_spent: 30, value_spent: 43.5}
                 ]
               }
             }
  end
end
