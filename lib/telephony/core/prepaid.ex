defmodule Telephony.Core.Prepaid do
  @moduledoc """
  Documentation for `Telephony.Core.Prepaid`.
  """

  alias Telephony.Core.Call
  @price_per_minute 1.45


  def make_call(%{subscriber_type: subscriber_type} = subscriber, time_spent, date) do
    credit_spent = @price_per_minute * time_spent
    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credit_spent}
    subscriber = %{subscriber | subscriber_type: subscriber_type}
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}

  end

  defstruct credits: 0, recharges: []
end
