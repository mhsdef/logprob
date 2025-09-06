defmodule LogProb do
  @moduledoc """
  A library for managing log probability values.

  LogProb provides a decimal-like API for working with log probabilities,
  including conversion to percentages and probabilities.
  """

  defstruct [:value]

  @type t :: %LogProb{value: Decimal.t()}

  @doc """
  Creates a new LogProb from a number or string.

  ## Examples

      iex> LogProb.new(-2.3026)
      %LogProb{value: Decimal.new("-2.3026")}

      iex> LogProb.new("-inf")
      %LogProb{value: Decimal.new("-Infinity")}
  """
  def new(value) when is_number(value) do
    %LogProb{value: Decimal.from_float(value)}
  end

  def new(value) when is_binary(value) do
    %LogProb{value: Decimal.new(value)}
  end

  def new(%Decimal{} = value) do
    %LogProb{value: value}
  end

  @doc """
  Creates a new LogProb from a probability value (0.0 to 1.0).

  ## Examples

      iex> LogProb.from_probability(0.1)
      #LogProb<-2.3025850929940455>

      iex> LogProb.from_probability(0.0)
      #LogProb<-Infinity>
  """
  def from_probability(prob) when is_number(prob) do
    cond do
      prob == 0.0 -> %LogProb{value: Decimal.new("-Infinity")}
      prob == 1.0 -> %LogProb{value: Decimal.new("0")}
      prob > 0.0 and prob < 1.0 -> %LogProb{value: Decimal.from_float(:math.log(prob))}
      true -> raise ArgumentError, "Probability must be between 0.0 and 1.0"
    end
  end

  @doc """
  Compares two LogProb values.

  ## Examples

      iex> a = LogProb.new(-1.0)
      iex> b = LogProb.new(-2.0)
      iex> LogProb.compare(a, b)
      :gt
  """
  def compare(%LogProb{value: a}, %LogProb{value: b}) do
    Decimal.compare(a, b)
  end

  @doc """
  Converts LogProb to probability (0.0 to 1.0 range).

  ## Examples

      iex> logprob = LogProb.new(-0.6931471805599453)
      iex> LogProb.to_probability(logprob)
      0.5

      iex> logprob = LogProb.new("-Infinity")
      iex> LogProb.to_probability(logprob)
      0.0
  """
  def to_probability(%LogProb{value: val}) do
    if Decimal.equal?(val, Decimal.new("-Infinity")) do
      0.0
    else
      :math.exp(Decimal.to_float(val))
    end
  end

  @doc """
  Converts LogProb to percentage with options.

  ## Options
  - `decimals`: Number of decimal places (default: 2)
  - `clamp`: Whether to clamp between 0 and 100 (default: true)
  - `percentage_symbol`: Whether to include % symbol (default: false)

  ## Examples

      iex> logprob = LogProb.new(-2.3026)
      iex> LogProb.to_percent(logprob)
      "10.00"

      iex> logprob = LogProb.new(-2.3026)
      iex> LogProb.to_percent(logprob, percentage_symbol: true)
      "10.00%"

      iex> logprob = LogProb.new(-2.3026)
      iex> LogProb.to_percent(logprob, decimals: 1)
      "10.0"
  """
  def to_percent(%LogProb{} = logprob, opts \\ []) do
    decimals = Keyword.get(opts, :decimals, 2)
    clamp = Keyword.get(opts, :clamp, true)
    percentage_symbol = Keyword.get(opts, :percentage_symbol, false)

    prob = to_probability(logprob)
    percent = prob * 100.0

    clamped_percent =
      if clamp do
        max(0.0, min(100.0, percent))
      else
        percent
      end

    formatted = :erlang.float_to_binary(clamped_percent, [{:decimals, decimals}])

    if percentage_symbol do
      formatted <> "%"
    else
      formatted
    end
  end

  @doc """
  Returns the raw Decimal value.

  ## Examples

      iex> logprob = LogProb.new(-2.3026)
      iex> LogProb.to_decimal(logprob)
      Decimal.new("-2.3026")
  """
  def to_decimal(%LogProb{value: val}), do: val

  @doc """
  Converts LogProb to string.

  ## Examples

      iex> logprob = LogProb.new(-2.3026)
      iex> LogProb.to_string(logprob)
      "-2.3026"
  """
  def to_string(%LogProb{value: val}), do: Decimal.to_string(val)

  defimpl String.Chars, for: LogProb do
    def to_string(logprob), do: LogProb.to_string(logprob)
  end

  defimpl Inspect, for: LogProb do
    def inspect(%LogProb{value: val}, _opts) do
      "#LogProb<#{Decimal.to_string(val)}>"
    end
  end
end
