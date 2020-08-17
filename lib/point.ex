defmodule Point do
  @moduledoc """
  Point represents a point in ℝ².
  """

  defstruct x: 0.0, y: 0.0

  @type t :: %Point{x: float, y: float}

  @doc """
  Returns the sum of two points.
  """
  @spec add(Point.t, Point.t) :: Point.t
  def add(p1, p2) do
    %Point{x: p1.x + p2.x, y: p1.y + p2.y}
  end

  @doc """
  Returns the difference between two points.
  """
  @spec sub(Point.t, Point.t) :: Point.t
  def sub(p1, p2) do
    %Point{x: p1.x - p2.x, y: p1.y - p2.y}
  end

  @doc """
  Returns the scalar product of a point and a value.
  """
  @spec mul(Point.t, float) :: Point.t
  def mul(%Point{x: x, y: y}, m) do
    %Point{x: m * x, y: m * y}
  end

  @doc """
  Returns a counterclockwise orthogonal point with the same norm.
  """
  @spec ortho(Point.t) :: Point.t
  def ortho(%Point{x: x, y: y}), do: %Point{x: -y, y: x}

  @doc """
  Returns the dot product between two points.
  """
  @spec dot(Point.t, Point.t) :: float
  def dot(p1, p2), do: p1.x * p2.x + p1.y * p2.y

  @doc """
  Returns the cross product of two points.
  """
  @spec cross(Point.t, Point.t) :: float
  def cross(p1, p2), do: p1.x * p2.y - p1.y * p2.x

  @doc """
  Returns the vector's norm.

  Todo: Implement hypotenuse function
  """
  @spec norm(Point.t) :: float
  def norm(%Point{x: x, y: y}) do
    :math.sqrt(x*x + y*y)
  end

  @doc """
  Returns a unit point in the same direction as the given point.
  """
  @spec normalize(Point.t) :: Point.t
  def normalize(%Point{x: x, y: y} = p) when x == 0 and y == 0, do: p

  def normalize(p) do
    p |> Point.mul(1 / Point.norm(p))
  end
end
