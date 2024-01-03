defmodule TelephonyTest do
  use ExUnit.Case

  setup do
    prepaid = %{full_name: "Kevin", phone_number: "123", type: :prepaid}

    %{prepaid: prepaid}
  end

  test "create subscriber", %{prepaid: prepaid} do
    assert Telephony.create_subscriber(prepaid) == [
             %Telephony.Core.Subscriber{
               full_name: "Kevin",
               phone_number: "123",
               type: %Telephony.Core.Prepaid{credits: 0, recharges: []},
               calls: []
             }
           ]
  end

  test "error when creating existing subscriber", %{prepaid: prepaid} do
    Telephony.create_subscriber(prepaid)
    assert Telephony.create_subscriber(prepaid) == {:error, "Subscriber `123` already exists"}
  end
end
