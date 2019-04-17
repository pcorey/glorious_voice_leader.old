defmodule Cubehelix do
  def colorizer(s \\ 0.5, r \\ -1.5, h \\ 1, g \\ 1) do
    fn d ->
      t = 2 * :math.pi() * (s / 3 + r * d)
      a = h * :math.pow(d, g) * (1 - :math.pow(d, g)) / 2
      cos = :math.cos(t)
      sin = :math.sin(t)

      {:math.pow(d, g) + a * dot(-0.14861, 1.78277, cos, sin),
       :math.pow(d, g) + a * dot(-0.29227, -0.90649, cos, sin),
       :math.pow(d, g) + a * dot(1.97294, 0, cos, sin)}
    end
  end

  def colorize(s, r, h, g, d) do
    colorizer(s, r, h, g).(d)
  end

  defp dot(a1, a2, b1, b2) do
    a1 * b1 + a2 * b2
  end
end
