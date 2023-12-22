defmodule Telephony.Core.Recharge do
  @moduledoc """
  Documentation for `Telephony.Core.Recharge`.
  """

  defstruct value: nil, date: nil

  def new(value, date \\ NaiveDateTime.utc_now()) do
    %__MODULE__{value: value, date: date}
  end
end
