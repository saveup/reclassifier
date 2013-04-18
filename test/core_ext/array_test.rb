require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ArrayTest < Test::Unit::TestCase
  def test_monkey_path_array_sum
    assert_equal [1,2,3].sum_with_identity, 6
  end

  def test_summing_an_empty_array
    assert_equal [nil].sum_with_identity, 0
  end

  def test_summing_an_empty_array
    assert_equal Array[].sum_with_identity, 0
  end
end
