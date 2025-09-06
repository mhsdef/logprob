defmodule LogProbTest do
  use ExUnit.Case
  doctest LogProb

  describe "new/1" do
    test "creates LogProb from number" do
      logprob = LogProb.new(-0.510826)
      assert %LogProb{value: %Decimal{}} = logprob
      assert Decimal.equal?(logprob.value, Decimal.new("-0.510826"))
    end

    test "creates LogProb from string" do
      logprob = LogProb.new("-1.38629")
      assert %LogProb{value: %Decimal{}} = logprob
      assert Decimal.equal?(logprob.value, Decimal.new("-1.38629"))
    end

    test "creates LogProb from Decimal" do
      decimal_val = Decimal.new("-2.99573")
      logprob = LogProb.new(decimal_val)
      assert %LogProb{value: ^decimal_val} = logprob
    end

    test "handles infinity" do
      logprob = LogProb.new("-Infinity")
      assert Decimal.equal?(logprob.value, Decimal.new("-Infinity"))
    end
  end

  describe "from_probability/1" do
    test "converts probability 0.3 to log probability" do
      logprob = LogProb.from_probability(0.3)
      expected = Decimal.from_float(:math.log(0.3))
      assert Decimal.equal?(logprob.value, expected)
    end

    test "converts probability 0.0 to negative infinity" do
      logprob = LogProb.from_probability(0.0)
      assert Decimal.equal?(logprob.value, Decimal.new("-Infinity"))
    end

    test "converts probability 1.0 to zero" do
      logprob = LogProb.from_probability(1.0)
      assert Decimal.equal?(logprob.value, Decimal.new("0"))
    end

    test "raises error for invalid probabilities" do
      assert_raise ArgumentError, fn -> LogProb.from_probability(-0.1) end
      assert_raise ArgumentError, fn -> LogProb.from_probability(1.1) end
    end
  end

  describe "compare/2" do
    test "compares log probabilities correctly" do
      a = LogProb.new(-0.5)
      b = LogProb.new(-1.2)
      c = LogProb.new(-0.5)

      assert LogProb.compare(a, b) === :gt
      assert LogProb.compare(b, a) === :lt
      assert LogProb.compare(a, c) === :eq
    end
  end

  describe "to_probability/1" do
    test "converts log probability to probability" do
      logprob = LogProb.new("-0.693147")
      prob = LogProb.to_probability(logprob)
      assert_in_delta prob, 0.5, 0.0005
    end

    test "converts zero log probability to 1.0" do
      logprob = LogProb.new(0.0)
      prob = LogProb.to_probability(logprob)
      assert prob === 1.0
    end

    test "converts negative infinity to 0.0" do
      logprob = LogProb.new("-Infinity")
      prob = LogProb.to_probability(logprob)
      assert prob === 0.0
    end
  end

  describe "to_percent/2" do
    test "converts to percentage with default options" do
      logprob = LogProb.new("-1.2039728")
      percent = LogProb.to_percent(logprob)
      assert percent === "30.00"
    end

    test "includes percentage symbol when requested" do
      logprob = LogProb.new("-1.2039728")
      percent = LogProb.to_percent(logprob, percentage_symbol: true)
      assert percent === "30.00%"
    end

    test "respects decimal places option" do
      logprob = LogProb.new("-1.2039728")
      percent = LogProb.to_percent(logprob, decimals: 1)
      assert percent === "30.0"

      percent = LogProb.to_percent(logprob, decimals: 3)
      assert percent === "30.000"
    end

    test "clamps by default" do
      # This would be > 100%
      logprob = LogProb.new(1.0)
      percent = LogProb.to_percent(logprob)
      assert percent === "100.00"

      # This would be 0%
      logprob = LogProb.new("-Infinity")
      percent = LogProb.to_percent(logprob)
      assert percent === "0.00"
    end

    test "doesn't clamp when clamp: false" do
      logprob = LogProb.new(1.0)
      percent = LogProb.to_percent(logprob, clamp: false)
      assert percent === "271.83"
    end

    test "combines all options" do
      logprob = LogProb.new(-1.6094)

      percent =
        LogProb.to_percent(logprob,
          decimals: 1,
          percentage_symbol: true,
          clamp: true
        )

      assert percent === "20.0%"
    end
  end

  describe "to_decimal/1" do
    test "returns the underlying decimal value" do
      decimal_val = Decimal.new("-2.99573")
      logprob = LogProb.new(decimal_val)
      result = LogProb.to_decimal(logprob)
      assert result === decimal_val
    end
  end

  describe "to_string/1" do
    test "converts to string representation" do
      # ln(0.75) ≈ -0.287682...
      logprob = LogProb.new("-0.28768")
      str = LogProb.to_string(logprob)
      assert str === "-0.28768"
    end
  end

  describe "String.Chars protocol" do
    test "works with Kernel.to_string/1" do
      logprob = LogProb.new("-0.28768")
      str = Kernel.to_string(logprob)
      assert str === "-0.28768"
    end
  end

  describe "Inspect protocol" do
    test "provides custom inspect format" do
      logprob = LogProb.new("-0.28768")
      inspected = inspect(logprob)
      assert inspected === "#LogProb<-0.28768>"
    end
  end

  describe "edge cases" do
    test "handles very small probabilities" do
      logprob = LogProb.from_probability(1.0e-10)
      prob = LogProb.to_probability(logprob)
      assert_in_delta prob, 1.0e-10, 1.0e-12
    end

    test "handles probabilities very close to 1" do
      logprob = LogProb.from_probability(0.9999999)
      prob = LogProb.to_probability(logprob)
      assert_in_delta prob, 0.9999999, 1.0e-8
    end

    test "percentage formatting with edge cases" do
      # Very small probability
      # Very small percentage
      logprob = LogProb.new(-10.0)
      percent = LogProb.to_percent(logprob, decimals: 6)
      assert percent === "0.004540"
    end
  end
end
