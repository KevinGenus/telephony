defmodule Telephony.Core.Pospaid do
  @moduledoc """
  Documentation for `Telephony.Core.Pospaid`.
  """

  defstruct spent: 0
  alias Telephony.Core.Call
  @price_per_minute 1.04

  def make_call(subscriber, time_spent, date) do
    subscriber
    |> update_spent(time_spent)
    |> add_new_call(time_spent, date)
  end

  defp update_spent(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    spent = @price_per_minute * time_spent
    subscriber_type = %{subscriber_type | spent: subscriber_type.spent + spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_new_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end
end
