defmodule X32Remote.Guards do
  defguard is_name(n) when is_pid(n) or is_atom(n)

  defguard is_volume(v)
           when (is_float(v) and v >= 0.0 and v <= 1.0) or
                  (is_integer(v) and v >= 0 and v <= 1023)

  defmodule Channels do
    def channel?("ch/" <> n), do: twodigit(n) in 1..32
    def channel?("auxin/" <> n), do: twodigit(n) in 1..8
    def channel?("fxrtn/" <> n), do: twodigit(n) in 1..8
    def channel?("bus/" <> n), do: twodigit(n) in 1..16
    def channel?("mtx/" <> n), do: twodigit(n) in 1..6
    def channel?("main/st"), do: true
    def channel?("main/m"), do: true
    def channel?(_), do: false

    # Yes I know String.to_integer/1 is a thing, but this is a fast
    # and simple way to ensure we get a two-digit zero-padded integer.
    @digits ?0..?9
    defp twodigit(<<0, n>>) when n in @digits, do: n - ?0
    defp twodigit(<<t, n>>) when t in @digits and n in @digits, do: (t - ?0) * 10 + n - ?0
    defp twodigit(_), do: nil

    def ensure_channel(ch) do
      unless channel?(ch) do
        raise "Invalid channel specifier: #{inspect(ch)}"
      end
    end
  end
end
