class Vector
  def magnitude
    sumsqs = 0.0
    self.size.times do |i|
      sumsqs += self[i] ** 2.0
    end
    Math.sqrt(sumsqs)
  end

  def normalize
    nv = []
    mag = self.magnitude
    self.size.times do |i|

      nv << (self[i] / mag)

    end
    Vector[*nv]
  end
end
