defmodule Oracle.Error do
  defexception [:message, :oracle]

  @nonposix_errors [:closed, :timeout]

  def message(e) do
    if kw = e.oracle do
      "#{kw[:severity]} (#{kw[:code]}): #{kw[:message]}"
    else
      e.message
    end
  end

  def exception([oracle: fields]) do
    fields = Enum.into(fields, %{})
             |> Map.put(:oracle_code, fields[:code])

    %Oracle.Error{oracle: fields}
  end

  def exception([tag: :ssl, action: action, reason: :timeout]) do
    %Oracle.Error{message: "ssl #{action}: timeout"}
  end

  def exception([tag: :ssl, action: action, reason: reason]) do
    formatted_reason = :ssl.format_error(reason)
    %Oracle.Error{message: "ssl #{action}: #{formatted_reason} - #{inspect(reason)}"}
  end

  def exception([tag: :tcp, action: action, reason: reason]) when not reason in @nonposix_errors do
    formatted_reason = :inet.format_error(reason)
    %Oracle.Error{message: "tcp #{action}: #{formatted_reason} - #{inspect(reason)}"}
  end

  def exception([tag: :tcp, action: action, reason: reason]) do
    %Oracle.Error{message: "tcp #{action}: #{reason}"}
  end

  def exception(arg) do
    super(arg)
  end
end
