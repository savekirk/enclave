defmodule EnclaveTest do
  use ExUnit.Case
  doctest Enclave
  alias Point, as: P
  alias Rect, as: R

  test "is enclaved by" do
    a = [%P{x: 1, y: 2}, %P{x: 1, y: 7}, %P{x: 5, y: 2}, %P{x: 5, y: 7}] |> R.from_points()
    b = [%P{x: 2, y: 4}, %P{x: 2, y: 6}, %P{x: 3, y: 4}, %P{x: 3, y: 6}] |> R.from_points()
    assert a
    |> R.contains?(b)
    refute b
    |> R.contains?(a)
  end
end
