# LogProb

`:logprob` is a small, focused libary to store, compare, and format probabilities in a safe way—without forcing you to become a math expert. You don’t have to “do math in log space” yourself.

Work with probabilities in a way that is:
- 🧱 Stable, avoid numerical underflow with very tiny probabilities
- ↔️ Easy to compare
- ％ Simple to format as a percentage
- 👀 Friendly to read in `iex`

Instead of juggling raw probabilities like `0.0000001234`, store their *logarithm* (the "log probability") and convert back only when you need a normal number or a percentage.

### Why “log” probabilities at all?

When you multiply several probabilities together (for example, combining independent chances), the numbers get very small very fast. Conceptually, computers can lose precision or round them down to zero.

Example:
- Normal probabilities: `0.01 * 0.02 * 0.03 * 0.05 = 0.0000003`
- That still looks OK, but keep chaining more and you’ll hit `0.0` in many computing environments.

With logs:
- You add instead of multiply (log turns multiplication into addition)
- You keep precision
- You can still get back the original probability or a readable percent

## Installation

Add to `mix.exs`:

```elixir
def deps do
  [
    {:logprob, "~> 0.1.0"}
  ]
end
```

## Plain Language Usage

A `LogProb` is just a tiny wrapper around `Decimal`:

```elixir
%LogProb{value: #Decimal<-2.3025850929940455>}
```

That decimal is the natural log (`:math.log/1`) of an ordinary probability between `0.0` and `1.0`.

- Probability 1.0 → log is `0`
- Probability 0.1 → log is about `-2.302585`
- Probability 0.0 → log is `-Infinity` (we store that explicitly)

Smaller probabilities = more negative log values.

### Creating `LogProb` values

Pick the constructor that matches what you have on hand.

```elixir
# From a raw log value (float):
LogProb.new(-1.386294361)

# From a normal probability (0.0–1.0):
LogProb.from_probability(0.25)

# From a string (including "-Infinity"):
LogProb.new("-Infinity")

# From an existing Decimal:
LogProb.new(Decimal.new("-2.3026"))
```

### Converting back

```elixir
lp = LogProb.from_probability(0.4)

LogProb.to_probability(lp)
#=> 0.4 (plain float)

LogProb.to_percent(lp)
#=> "40.00"

LogProb.to_percent(lp, decimals: 1, percentage_symbol: true)
#=> "40.0%"
```

### Comparing

`LogProb.compare/2` returns:
- `:gt` (greater than)
- `:lt` (less than)
- `:eq` (equal)

Greater means “represents a higher probability”.

```elixir
a = LogProb.from_probability(0.6)
b = LogProb.from_probability(0.2)
LogProb.compare(a, b)
#=> :gt
```

## FAQ

Q: Do I need to know logarithms to use this?
A: No. Treat `LogProb` as a probability wrapper.

Q: Why are the numbers negative?
A: Because logs of numbers between 0 and 1 are negative. Closer to zero = more likely.

Q: Can I add two `LogProb` values?
A: Not yet. Today this library focuses on representation, conversion, and comparison. Future versions might include safe combination helpers.

Q: What about base-10 logs?
A: This uses natural log (base e). That’s standard for probability work.

Q: Will precision drift?
A: Internally we store a `Decimal`, and convert through floats only when necessary (e.g. `:math.exp`). Decimal does an excellent job in its concerns so we expect our (very slight) extension here to be fine for typical application-level usage.
