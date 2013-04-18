class Array
  def sum_with_identity(identity = 0, &block)
    return identity unless size > 0

    if block_given?
      map(&block).sum
    else
      reduce(:+)
    end
  end
end
