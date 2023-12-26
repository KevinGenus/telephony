defmodule Telephony.CoreTest do
  use ExUnit.Case
  alias Telephony.Core
  alias Telephony.Core.{Pospaid, Prepaid, Recharge, Subscriber}

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Kevin",
        phone_number: "123",
        type: %Prepaid{credits: 0, recharges: []}
      },
      %Subscriber{
        full_name: "Kevin",
        phone_number: "1234",
        type: %Pospaid{spent: 0}
      }
    ]

    payload = %{
      full_name: "Kevin",
      phone_number: "123",
      type: :prepaid
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
        type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    assert expect == result
  end

  test "create a new subscriber", %{subscribers: subscribers} do
    payload = %{
      full_name: "Joe",
      phone_number: "12345",
      type: :prepaid
    }

    result = Core.create_subscriber(subscribers, payload)

    expect = [
      %Subscriber{
        calls: [],
        full_name: "Kevin",
        phone_number: "123",
        type: %Prepaid{
          credits: 0,
          recharges: []
        }
      },
      %Subscriber{
        full_name: "Kevin",
        phone_number: "1234",
        type: %Pospaid{spent: 0},
        calls: []
      },
      %Subscriber{
        full_name: "Joe",
        phone_number: "12345",
        type: %Prepaid{credits: 0, recharges: []},
        calls: []
      }
    ]

    assert expect == result
  end

  test "display error, when subscriber already exists", %{
    subscribers: subscribers,
    payload: payload
  } do
    result = Core.create_subscriber(subscribers, payload)
    assert {:error, "Subscriber `123` already exists"} == result
  end

  test "display error, when type does not exist ", %{payload: payload} do
    payload = Map.put(payload, :type, :asdf)
    result = Core.create_subscriber([], payload)
    assert {:error, "Only 'prepaid' or 'pospaid' are accepted"} == result
  end

  test "search for a subscriber", %{subscribers: subscribers} do
    expect = %Subscriber{
      full_name: "Kevin",
      phone_number: "123",
      type: %Prepaid{credits: 0, recharges: []}
    }

    result = Core.search_subscriber(subscribers, "123")
    assert expect == result
  end

  test "return nil when subscriber does not exist", %{subscribers: subscribers} do
    result = Core.search_subscriber(subscribers, "1231231234")
    assert nil == result
  end

  test "make a recharge prepaid", %{subscribers: subscribers} do
    date = Date.utc_today()
    result = Core.make_recharge(subscribers, "123", 2, date)

    assert result ==
             {[
                %Subscriber{
                  full_name: "Kevin",
                  phone_number: "1234",
                  type: %Pospaid{spent: 0},
                  calls: []
                },
                %Subscriber{
                  full_name: "Kevin",
                  phone_number: "123",
                  type: %Prepaid{
                    credits: 2,
                    recharges: [%Recharge{value: 2, date: date}]
                  },
                  calls: []
                }
              ],
              %Telephony.Core.Subscriber{
                full_name: "Kevin",
                phone_number: "123",
                type: %Telephony.Core.Prepaid{
                  credits: 2,
                  recharges: [%Telephony.Core.Recharge{value: 2, date: date}]
                },
                calls: []
              }}
  end

  test "make a recharge pospaid", %{subscribers: subscribers} do
    date = Date.utc_today()
    result = Core.make_recharge(subscribers, "123", 2, date)

    assert result ==
             {[
                %Subscriber{
                  full_name: "Kevin",
                  phone_number: "1234",
                  type: %Pospaid{spent: 0},
                  calls: []
                },
                %Subscriber{
                  full_name: "Kevin",
                  phone_number: "123",
                  type: %Prepaid{
                    credits: 2,
                    recharges: [%Recharge{value: 2, date: date}]
                  },
                  calls: []
                }
              ],
              %Subscriber{
                full_name: "Kevin",
                phone_number: "123",
                type: %Prepaid{
                  credits: 2,
                  recharges: [%Recharge{value: 2, date: date}]
                },
                calls: []
              }}
  end

  test "make a call", %{subscribers: subscribers} do
    expected =
      {[
         %Subscriber{
           full_name: "Kevin",
           phone_number: "1234",
           type: %Pospaid{spent: 0},
           calls: []
         }
       ], {:error, "Subscriber does not have credits"}}

    date = Date.utc_today()
    result = Core.make_call(subscribers, "123", 1, date)

    assert expected == result
  end

  test "print invoice", %{subscribers: subscribers} do
    expected =
      %{
        invoice: %{recharges: [], calls: []},
        subscriber: %Subscriber{
          full_name: "Kevin",
          phone_number: "123",
          type: %Prepaid{credits: 0, recharges: []},
          calls: []
        }
      }

    date = Date.utc_today()
    result = Core.print_invoice(subscribers, "123", date.year, date.month)

    assert expected == result
  end

  test "print all invoices", %{subscribers: subscribers} do
    expected = [
      %{
        invoice: %{recharges: [], calls: []},
        subscriber: %Subscriber{
          full_name: "Kevin",
          phone_number: "123",
          type: %Prepaid{credits: 0, recharges: []},
          calls: []
        }
      },
      %{
        invoice: %{calls: [], value_spent: 0},
        subscriber: %Subscriber{
          full_name: "Kevin",
          phone_number: "1234",
          type: %Pospaid{spent: 0},
          calls: []
        }
      }
    ]

    date = Date.utc_today()
    result = Core.print_invoices(subscribers, date.year, date.month)

    assert expected == result
  end
end
