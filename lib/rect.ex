defmodule Rect do
  @moduledoc """
  Represents a closed axis-aligned rectangle in the (x,y) plane.
  """
  defstruct x: %Interval{}, y: %Interval{}

  @type t :: %Rect{x: Interval.t, y: Interval.t}

  @doc """
  Constructs a rect that contains the given points.

  Because the default value on interval is 0,0,
  we need to manually define the interval from the first
  point passed in as our starting interval,
  otherwise we end up with the case of passing in
  Point{0.2, 0.3} and getting the starting Rect of {0, 0.2}, {0, 0.3}
  instead of the Rect {0.2, 0.2}, {0.3, 0.3} which is not correct.
  """
  @spec from_points(List[Point.t]) :: Rect.t
  def from_points([]), do: %Rect{}

  def from_points([p | pts]) do
    %Rect{
      x: %Interval{lo: p.x, hi: p.x},
      y: %Interval{lo: p.y, hi: p.y}
    } |> from_points(pts)
  end

  @spec from_points(Rect.t, List[Point.t]) :: Rect.t
  defp from_points(rect, []) do
    rect
  end

  defp from_points(rect, [p | pts]) do
    rect |> add_point(p) |> from_points(pts)
  end

  @doc """
  Constructs a rectangle with the given center and size.
  Both dimensions of size must be non-negative
  """
  @spec from_center_size(Point.t, Point.t) :: Rect
  def from_center_size(%Point{x: cx, y: cy}, %Point{x: sx, y: sy}) do
    %Rect{
    x: %Interval{lo: cx - sx/2, hi: cx + sx/2},
    y: %Interval{lo: cy - sy/2, hi: cy + sy/2}
    }
  end

  @doc """
  Constructs the conomical empty rectangle.

  Use Rect.is_empty() to test for empty rectangles,
  since they have more than one representation.
  A %Rect{} is not the same as the Rect.empty_rect()
  """
  @spec empty_rect :: Rect.t
  def empty_rect do
    %Rect{
    x: Interval.empty_interval(),
    y: Interval.empty_interval()
    }
  end

  @doc """
  Reports whether the rectangle is valid.

  This requires the width to be empty iff the height is empty.
  """
  @spec is_valid?(Rect.t) :: boolean
  def is_valid?(%Rect{x: x, y: y}) do
    Interval.is_empty?(x) == Interval.is_empty?(y)
  end

  @doc """
  Checks if a rectangle is empty.
  """
  @spec is_empty?(Rect.t) :: boolean
  def is_empty?(%Rect{x: x}), do: Interval.is_empty?(x)

  @doc """
  Returns all four vertices of the rectangle.

  Vertices are returned in CCW direction starting with the lowe left corner.
  """
  @spec vertices(Rect.t) :: [Point.t]
  def vertices(%Rect{x: x, y: y}) do
    [
    %Point{x: x.lo, y: y.lo},
    %Point{x: x.hi, y: y.lo},
    %Point{x: x.hi, y: y.hi},
    %Point{x: x.lo, y: y.hi}
    ]
  end

  @doc """
  Returns the vertex in direction i along the X-axis
  (0=left, 1=right) and direction j along the Y-axis (0=down, 1=up).
  """
  @spec vertex_ij(Rect.t, integer, integer) :: Point.t
  def vertex_ij(%Rect{x: x, y: y}, i, j) when i == 1 do
    py = case j == 1 do
       true -> y.hi
       false -> y.lo
    end

    %Point{x: x.hi, y: py}
  end

  def vertex_ij(%Rect{x: x, y: y}, i, j) when j == 1 do
    px = case i == 1 do
       true -> x.hi
       false -> x.lo
    end

    %Point{x: px, y: y.hi}
  end

  def vertex_ij(%Rect{x: x, y: y}, _, _) do
    %Point{x: x.lo, y: y.hi}
  end

  @doc """
  Returns the low corner of the rectangle.
  """
  @spec lo(Rect.t) :: Point.t
  def lo(%Rect{x: x, y: y}), do: %Point{x: x.lo, y: y.lo}

  @doc """
  Returns the high corner of the rectangle.
  """
  @spec hi(Rect.t) :: Point.t
  def hi(%Rect{x: x, y: y}), do: %Point{x: x.hi, y: y.hi}

  @doc """
  Returns the center of the rectangle in (x,y)-space
  """
  @spec center(Rect.t) :: Point.t
  def center(%Rect{x: x, y: y}) do
    %Point{
      x: x |> Interval.center(),
      y: y |> Interval.center()
    }
  end

  @doc """
  Returns the width and height of a given rectangle in (x,y)-space.

  Empty rectangles have a negative width and height.
  """
  @spec size(Rect.t) :: Point.t
  def size(%Rect{x: x, y: y}) do
    %Point{
      x: x |> Interval.length(),
      y: y |> Interval.length()
    }
  end

  @doc """
  Reports whether the rectanglea contains the given point.

  Rectangles are closed regions, i.e. they contain their boundary.
  """
  @spec contains_point?(Rect.t, Point.t) :: boolean
  def contains_point?(%Rect{x: rx, y: ry}, %Point{x: px, y: py}) do
    rx |> Interval.contains?(px) && ry |> Interval.contains?(py)
  end

  @doc """
  Returns true iff the given point is contained in the interior
  of the region (i.e. the region excluding its boundary).
  """
  @spec interior_contains_point?(Rect.t, Point.t) :: boolean
  def interior_contains_point?(%Rect{x: rx, y: ry}, %Point{x: px, y: py}) do
    rx |> Interval.interior_contains?(px) &&
    ry |> Interval.interior_contains?(py)
  end

  @doc """
  Checks whether the rectangle contains the given rectangle.
  """
  @spec contains?(Rect.t, Rect.t) :: boolean
  def contains?(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    r1x |> Interval.contains_interval?(r2x) &&
    r1y |> Interval.contains_interval?(r2y)
  end

  @doc """
  Checks whether the interior of a rectangle contains all of the
  points of another rectangle (including its boundary).
  """
  @spec interior_contains?(Rect.t, Rect.t) :: boolean
  def interior_contains?(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    r1x |> Interval.interior_contains_interval?(r2x) &&
    r1y |> Interval.interior_contains_interval?(r2y)
  end

  @doc """
  Checks whether two rectangles have any points in common.
  """
  @spec intersects?(Rect.t, Rect.t) :: boolean
  def intersects?(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    r1x |> Interval.intersects?(r2x) &&
    r1y |> Interval.intersects?(r2y)
  end

  @doc """
  Given two rectangles, check if the interior of the first rectangle
  intersects any point (including boundary) of the second rectangle
  """
  @spec interior_intersects?(Rect.t, Rect.t) :: boolean
  def interior_intersects?(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    r1x |> Interval.interior_intersects?(r2x) &&
    r1y |> Interval.interior_intersects?(r2y)
  end

  @doc """
  Expands the rectangle to include the given point.

  The rectangle is expanded by the minimum amount possible.
  """
  @spec add_point(Rect.t, Point.t) :: Rect.t
  def add_point(%Rect{x: rx, y: ry}, %Point{x: px, y: py}) do
    %Rect{
      x: rx |> Interval.add_point(px),
      y: ry |> Interval.add_point(py)
    }
  end

  @doc """
  Expands the rectangle to include the given rectangle.

  This is the same as replacing the rectangle by the union of the two rectangles,
  but is more efficient.
  """
  @spec add_rect(Rect.t, Rect.t) :: Rect.t
  def add_rect(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    %Rect{
      x: r1x |> Interval.union(r2x),
      y: r1y |> Interval.union(r2y)
    }
  end

  @doc """
  Returns the closest point in the rectangle to the given point.

  The rectangle must be non-empty
  """
  @spec clamp_point(Rect.t, Point.t) :: Point.t
  def clamp_point(%Rect{x: rx, y: ry}, %Point{x: px, y: py}) do
    %Point{
      x: rx |> Interval.clamp_point(px),
      y: ry |> Interval.clamp_point(py)
    }
  end

  @doc """
  Returns a rectangle that has been expanded in the x-direction by
  margin.x, and in y-direction by margin.y.

  If either margin is empty,then shrink the interval on the corresponding sides instead.
  The resulting rectangle may be empty. Any expansion of an empty rectangleremains empty.
  """
  @spec expanded(Rect.t, Point.t) :: Rect.t
  def expanded(%Rect{x: rx, y: ry}, %Point{x: px, y: py}) do
    xx = rx |> Interval.expanded(px)
    yy = ry |> Interval.expanded(py)
    cond do
      xx |> Interval.is_empty?() || yy |> Interval.is_empty?() -> Rect.empty_rect()
      true -> %Rect{x: xx, y: yy}
    end
  end

  @doc """
  Returns a rectangle that has been expanded by the amount on all sides.
  """
  @spec expanded_by_margin(Rect.t, float) :: Rect.t
  def expanded_by_margin(rect, margin) do
    rect |> expanded(%Point{x: margin, y: margin})
  end

  @doc """
  Returns the smallest rectangle containing the union of two given rectangles
  """
  @spec union(Rect.t, Rect.t) :: Rect.t
  def union(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    %Rect{
      x: r1x |> Interval.union(r2x),
      y: r1y |> Interval.union(r2y)
    }
  end

  @doc """
  Returns the smallest rectangle containing the intersection of two rectangles.
  """
  @spec intersection(Rect.t, Rect.t) :: Rect.t
  def intersection(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    xx = r1x |> Interval.intersection(r2x)
    yy = r1y |> Interval.intersection(r2y)
    cond do
      xx |> Interval.is_empty?() || yy |> Interval.is_empty?() -> Rect.empty_rect()
      true -> %Rect{x: xx, y: yy}
    end
  end

  @doc """
  Returns true if the x and y intervals of the two rectangles are the same
  up to the given tolerance.
  """
  @spec approx_equal?(Rect.t, Rect.t) :: boolean
  def approx_equal?(%Rect{x: r1x, y: r1y}, %Rect{x: r2x, y: r2y}) do
    r1x |> Interval.approx_equal?(r2x) &&
    r1y |> Interval.approx_equal?(r2y)
  end

end
