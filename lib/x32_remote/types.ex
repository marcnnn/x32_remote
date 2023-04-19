defmodule X32Remote.Types do
  defguard is_name(n) when is_pid(n) or is_atom(n)

  defguard is_slider(v, max)
           when (is_float(v) and v >= 0.0 and v <= 1.0) or
                  (is_integer(v) and v >= 0 and v <= max)

  defguard is_volume(v) when is_slider(v, 1023)
  defguard is_mono_level(v) when is_slider(v, 160)
  defguard is_percent(v) when is_slider(v, 100)

  def to_boolean([0]), do: false
  def to_boolean([1]), do: true

  def to_float([f]) when is_float(f), do: f

  defmodule Channels do
    def channel?("ch/" <> id), do: check_twodigit(id, 1..32)
    def channel?("auxin/" <> id), do: check_twodigit(id, 1..8)
    def channel?("fxrtn/" <> id), do: check_twodigit(id, 1..8)
    def channel?("bus/" <> id), do: check_twodigit(id, 1..16)
    def channel?("mtx/" <> id), do: check_twodigit(id, 1..6)
    def channel?("main/st"), do: true
    def channel?("main/m"), do: true
    def channel?(_), do: false

    # Yes I know String.to_integer/1 is a thing, but this is a fast
    # and simple way to ensure we get a two-digit zero-padded integer.
    @digits ?0..?9
    def from_twodigit(<<t, n>>) when t in @digits and n in @digits, do: (t - ?0) * 10 + n - ?0

    def to_twodigit(n) when n >= 0 and n <= 9, do: "0#{n}"
    def to_twodigit(n) when n >= 10 and n <= 99, do: "#{n}"

    defp check_twodigit(str, range) do
      try do
        from_twodigit(str) in range
      rescue
        FunctionClauseError -> false
      end
    end

    def ensure_channel(ch) do
      unless channel?(ch) do
        raise "Invalid channel specifier: #{inspect(ch)}"
      end
    end
  end
end
