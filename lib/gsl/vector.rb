class GSL::Vector
  def _dump(v)
    Marshal.dump( self.to_a )
  end

  def self._load(arr)
    arry = Marshal.load(arr)
    return GSL::Vector.alloc(arry)
  end
end
