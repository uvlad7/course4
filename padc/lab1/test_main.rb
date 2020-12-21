require_relative 'main'
require 'test/unit'

class TestMain < Test::Unit::TestCase
  def check_sizes(n1, n2, n3, bs)
    if RANK == 0
      a = generate_random_matrix(n1, n2)
      b = generate_random_matrix(n2, n3)
      et = (Matrix.build(n1, n2) { |row, col| a[n2 * row + col] } * Matrix.build(n2, n3) { |row, col| b[n3 * row + col] }).to_a.flatten
      [nil, :outer, :inner].each do |type|
        c = generate_res_matrix(n1, n3)
        point_multiply(a, b, c, n1, n2, n3, type)
        assert_equal(et, c.to_a)
        c = generate_res_matrix(n1, n3)
        block_multiply(a, b, c, n1, n2, n3, bs, type)
        assert_equal(et, c.to_a)
      end
    end
  end

  def test_simple
    check_sizes(10, 20, 30, 5)
  end

  def test_block_not_multiple_size
    check_sizes(10, 20, 30, 7)
  end

  def test_block_greater_than_size
    check_sizes(10, 12, 30, 13)
  end

  def test_first_size_less_than_processes_count
    unless SIZE == 1
      check_sizes(SIZE - 1, 12, 30, 5)
    end
  end

  def test_second_size_less_than_processes_count
    unless SIZE == 1
      check_sizes(10, SIZE - 1, 30, 5)
    end
  end

  def test_third_size_less_than_processes_count
    unless SIZE == 1
      check_sizes(10, 12, SIZE - 1, 5)
    end
  end

  def test_all_sizes_less_than_processes_count
    unless SIZE == 1
      check_sizes(SIZE - 1, SIZE - 1, SIZE - 1, 5)
    end
  end
end