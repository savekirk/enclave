defmodule Interval do
  @moduledoc """
    Interval represents a closed interval on ℝ.
    Zero-length intervals (where lo == hi) represent single points.
    If lo > hi then the interval is empty
  """

  @episilon 1.0e-14

  defstruct lo: 0.0, hi: 0.0

  @type t :: %Interval{lo: float, hi: float}

  @doc """
  Returns an empty interval
  """
  @spec empty_interval() :: Interval.t
  def empty_interval(), do: %Interval{lo: 1.0, hi: 0.0}

  @doc """
  Returns an interval representing a single point.
  """
  @spec from_point(float) :: Interval.t
  def from_point(point) do
    %Interval{lo: point, hi: point}
  end

  @doc """
  Reports whether the interval is empty.
  """
  @spec is_empty?(Interval.t) :: boolean
  def is_empty?(%Interval{lo: lo, hi: hi}) do
    lo > hi
  end

  @doc """
  Checks if two intervals are equals.

  Two intervals are equals iff they contain same points.
  """
  @spec equal?(Interval.t, Interval.t) :: boolean
  def equal?(interval1, interval2) do
    Map.equal?(interval1, interval2)
    || Interval.is_empty?(interval1) && Interval.is_empty?(interval2)
  end

  @doc """
  Returns the midpoint of a given interval
  """
  @spec center(Interval.t) :: float
  def center(%Interval{lo: lo, hi: hi}) do
    0.5 * (lo + hi)
  end

  @doc """
  Returns the length of an interval

  Length of an empty interval is negative
  """
  @spec length(Interval.t) :: float
  def length(%Interval{lo: lo, hi: hi}) do
    hi - lo
  end

  @doc """
  Returns true if an interval contains a given point
  """
  @spec contains?(Interval.t, float) :: boolean
  def contains?(%Interval{lo: lo, hi: hi}, point) do
    lo <= point && point <= hi
  end

  @doc """
  Returns true if interval1 contains interval2
  """
  @spec contains_interval?(Interval.t, Interval.t) :: boolean
  def contains_interval?(interval1, interval2) do
    Interval.is_empty?(interval2)
    || (interval1.lo <= interval2.lo && interval2.hi <= interval1.hi)
  end

  @doc """
  Returns true if interval1 strictly contains point
  """
  @spec interior_contains?(Interval.t, float) :: boolean
  def interior_contains?(%Interval{lo: lo, hi: hi}, point) do
    lo < point && point < hi
  end

  @doc """
  Returns true if interval1 strictly contains interval2
  """
  @spec interior_contains_interval?(Interval.t, Interval.t) :: boolean
  def interior_contains_interval?(interval1, interval2) do
    Interval.is_empty?(interval2)
    || (interval1.lo < interval2.lo && interval2.hi < interval1.hi)
  end

  @doc """
  Check if two intervals have any point in common
  """
  @spec intersects?(Interval.t, Interval.t) :: boolean
  def intersects?(%Interval{lo: lo1, hi: hi1}, %Interval{lo: lo2, hi: hi2}) when lo1 <= lo2 do
    lo2 <= hi1 && lo2 <= hi2
  end

  def intersects?(interval1, interval2) do
    interval1.lo <= interval2.hi && interval1.lo <= interval1.hi
  end

  @doc """
  Returns true if the interior of interval1 contains any points in common with interval2
  including the boundary of interval2
  """
  @spec interior_intersects?(Interval.t, Interval.t) :: boolean
  def interior_intersects?(i1, i2) do
    i2.lo < i1.hi && i1.lo < i2.hi && i1.lo < i1.hi && i2.lo <= i2.hi
  end

  @doc """
  Returns the interval containing all points common to i1 and i2
  """
  @spec intersection(Interval.t, Interval.t) :: Interval.t
  def intersection(i1, i2) do
    %Interval{lo: max(i1.lo, i2.lo), hi: min(i1.hi, i2.hi)}
  end

  @doc """
  Returns the interval expanded so that it contains the given point
  """
  @spec add_point(Interval.t, float) :: Interval.t
  def add_point(%Interval{lo: lo, hi: hi} = i, p) do
    {l, h} = cond do
      Interval.is_empty?(i) -> {p, p}
      p < lo -> {p, hi}
      p > hi -> {lo, p}
      true -> {lo, hi}
    end

    %Interval{lo: l, hi: h}
  end

  @doc """
  Returns the closest point in an interval to a given point

  The interval must be non-empty
  """
  @spec clamp_point(Interval.t, float) :: float
  def clamp_point(%Interval{lo: lo, hi: hi}, p) do
    max(lo, min(hi, p))
  end

  @doc """
  Returns an interval that has been expanded on each side by margin.
  If margin is negative, then the function shrinks the interval on each
  side by margin instead. The resulting interval may be empty.
  Any expansion of an empty interval remains empty.
  """
  @spec expanded(Interval.t, float) :: Interval.t
  def expanded(%Interval{lo: lo, hi: hi} = i, _) when lo > hi, do: i

  def expanded(%Interval{lo: lo, hi: hi}, margin) do
    %Interval{lo: lo - margin, hi: hi + margin}
  end

  @doc """
  Returns the smallest internal between two given interval
  """
  @spec union(Interval.t, Interval.t) :: Interval.t
  def union(%Interval{lo: lo, hi: hi}, i2) when lo > hi,  do: i2

  def union(i1, %Interval{lo: lo, hi: hi}) when lo > hi,  do: i1

  def union(i1, i2) do
    %Interval{lo: min(i1.lo, i2.lo), hi: max(i1.hi, i2.hi)}
  end

  @doc """
  Reports whether the interval can be transformed into the
  given interval by moving each endpoint a small distance.
  The empty interval is considered to be positioned arbitrarily on the
  real line, so any interval with a small enough length will match
  the empty interval.
  """
  @spec approx_equal?(Interval.t, Interval.t) :: boolean
  def approx_equal?(%Interval{lo: lo, hi: hi}, i2) when lo > hi do
    Interval.length(i2) <= 2 * @episilon
  end

  def approx_equal?(i1, %Interval{lo: lo, hi: hi}) when lo > hi do
    Interval.length(i1) <= 2 * @episilon
  end

  def approx_equal?(i1, i2) do
    abs(i2.lo - i1.lo) <= @episilon && abs(i2.hi - i1.hi) <= @episilon
  end

end
