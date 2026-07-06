# A single line comment.

defmodule Greeter do
  @moduledoc """
  Greets people and computes Fibonacci numbers.
  """

  @default_name "world"

  @doc "Return a greeting for `name`."
  @spec greet(String.t()) :: String.t()
  def greet(name \\ @default_name) do
    "Hello, #{name}!"
  end

  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when is_integer(n) and n > 1 do
    fib(n - 1) + fib(n - 2)
  end

  def run do
    names = ~w(Alice Bob Carol)

    names
    |> Enum.map(&greet/1)
    |> Enum.each(&IO.puts/1)

    config = %{retries: 3, timeout: 5_000, tags: [:fast, :safe]}
    IO.inspect(config, label: :config)

    for n <- 0..10, rem(n, 2) == 0, do: fib(n)
  end
end
