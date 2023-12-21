defmodule Telephony.Core.Call do
  @moduledoc """
  Documentation for `Telephony.Core.Call`.
  """

  defstruct time_spent: nil, date: nil

  def new(time_spent, date) do
    %__MODULE__{time_spent: time_spent, date: date}
  end
end
