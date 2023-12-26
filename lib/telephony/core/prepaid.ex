defmodule Telephony.Core.Prepaid do
  @moduledoc """
  Documentation for `Telephony.Core.Prepaid`.
  """

  defstruct credits: 0, recharges: []
  alias Telephony.Core.{Call, Recharge}

  defimpl Subscriber, for: Telephony.Core.Prepaid do
    @price_per_minute 1.45

    def print_invoice(%{recharges: recharges} = _type, calls, year, month) do
      recharges = Enum.filter(recharges, &(&1.date.year == year and &1.date.month == month))

      calls =
        Enum.reduce(calls, [], fn call, acc ->
          if call.date.year == year and call.date.month == month do
            value_spent = call.time_spent * @price_per_minute
            call = %{date: call.date, time_spent: call.time_spent, value_spent: value_spent}

            acc ++ [call]
          else
            acc
          end
        end)

      %{
        recharges: recharges,
        calls: calls
      }
    end

    def make_call(type, time_spent, date) do
      if maybe_subscriber_has_credits?(type, time_spent) do
        type
        |> update_credit_spent(time_spent)
        |> add_new_call(time_spent, date)
      else
        {:error, "Subscriber does not have credits"}
      end
    end

    defp update_credit_spent(type, time_spent) do
      credit_spent = @price_per_minute * time_spent
      %{type | credits: type.credits - credit_spent}
    end

    defp add_new_call(type, time_spent, date) do
      call = Call.new(time_spent, date)
      {type, call}
    end

    def make_recharge(type, value, date) do
      recharge = Recharge.new(value, date)

      %{
        type
        | recharges: type.recharges ++ [recharge],
          credits: type.credits + recharge.value
      }
    end

    defp maybe_subscriber_has_credits?(type, time_spent) do
      type.credits >= @price_per_minute * time_spent
    end
  end
end
