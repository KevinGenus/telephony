defprotocol Telephony.Core.Invoice do
  @fallback_to_any true
  def print(subscriber_type, calls, year, month)
  def subscriber_type(subscriber_type)
end
