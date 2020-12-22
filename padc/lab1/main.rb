# mpirun -np 4 ruby main.rb
# frozen_string_literal: true
require 'mpi'
require 'pry'
require 'matrix'
require 'benchmark'

include NumRu

MPI.Init
puts
WORLD = MPI::Comm::WORLD
RANK = WORLD.rank
SIZE = WORLD.size


def point_multiply(a, b, res, n1, n2, n3, parallelization = nil)
  case parallelization
  when :outer
    outer_cycle(a, b, res, n1, n2, n3) do |a_part, res_part, part_size_n1|
      point_multiply_non_parallel(a_part, b, res_part, part_size_n1, n2, n3)
    end
  when :inner
    inner_cycle(a, b, res, n1, n2, n3) do |b_part, res_part, i, part_size_n2, offset|
      inner_point_multiply_non_parallel(a, b_part, res_part, i, part_size_n2, n3, offset)
    end
  else
    if RANK == 0
      point_multiply_non_parallel(a, b, res, n1, n2, n3)
    end
  end
  res
end

def block_multiply(a, b, res, n1, n2, n3, block_size, parallelization = nil)
  case parallelization
  when :outer
    outer_cycle(a, b, res, n1, n2, n3) do |a_part, res_part, part_size_n1|
      block_multiply_non_parallel(a_part, b, res_part, part_size_n1, n2, n3, block_size)
    end
  when :inner
    inner_cycle(a, b, res, n1, n2, n3) do |b_part, res_part, i, part_size_n2, offset|
      inner_block_multiply_non_parallel(a, b_part, res_part, i, part_size_n2, n3, offset, block_size)
    end
  else
    if RANK == 0
      block_multiply_non_parallel(a, b, res, n1, n2, n3, block_size)
    end
  end
  res
end

def generate_random_matrix(rows, cols)
  matrix = NArray.int(rows * cols)
  matrix.size.times { |i| matrix[i] = rand(-100..100) } if RANK == 0
  matrix
end

def generate_res_matrix(rows, cols)
  NArray.int(rows * cols)
end

def part_size(size, rank = RANK, parts = SIZE)
  res = (size.to_f / parts).floor
  res += 1 if size - (res * parts) > rank
  res
end

def outer_cycle(a, b, res, n1, n2, n3, &block)
  part_size_n1 = part_size(n1)
  if part_size_n1 > 0
    WORLD.Bcast(b, 0)
    if RANK == 0
      prev = part_size_n1 * n2
      a_part = a[0...prev]
      (1...SIZE).each do |dest|
        size = part_size(n1, dest) * n2
        WORLD.Send(a[prev...(prev + size)], dest, 1) if size > 0
        prev += size
      end
    else
      a_part = NArray.int(part_size_n1 * n2)
      WORLD.Recv(a_part, 0, 1, part_size_n1 * n2)
    end
    res_part = NArray.int(part_size_n1 * n3)
    block.call(a_part, res_part, part_size_n1)
    if RANK == 0
      prev = part_size_n1 * n3
      res[0...prev] = res_part
      (1...SIZE).each do |dest|
        size = part_size(n1, dest) * n3
        WORLD.Recv(res, dest, 2, size, prev) if size > 0
        prev += size
      end
    else
      WORLD.Send(res_part, 0, 2)
    end
  end
  WORLD.Barrier
end

def inner_cycle(a, b, res, n1, n2, n3, &block)
  WORLD.Bcast(a, 0)
  part_size_n2 = part_size(n2)
  n1.times do |i|
    if part_size_n2 > 0
      if RANK == 0
        prev = part_size_n2 * n3
        b_part = b[0...prev]
        (1...SIZE).each do |dest|
          size = part_size(n2, dest) * n3
          WORLD.Send(b[prev...(prev + size)], dest, 1) if size > 0
          prev += size
        end
      else
        b_part = NArray.int(part_size_n2 * n3)
        WORLD.Recv(b_part, 0, 1, part_size_n2 * n3)
      end
      res_part = NArray.int(n3)
      block.call(b_part, res_part, i, part_size_n2, part_size(n2, 0) * RANK)
      if RANK == 0
        range = (i * n3...((i + 1) * n3))
        res[range] = res_part
        (1...SIZE).each do |dest|
          if part_size(n2, dest) > 0
            WORLD.Recv(res_part, dest, 2, n3)
            res[range] += res_part
          end
        end
      else
        WORLD.Send(res_part, 0, 2)
      end
    end
    WORLD.Barrier
  end
end

def inner_point_multiply_non_parallel(a, b, res, i, n2, n3, offset)
  n3.times do |j|
    n2.times do |k|
      res[j] += a[i * n2 + k + offset] * b[k * n3 + j]
    end
  end
end

def point_multiply_non_parallel(a, b, res, n1, n2, n3)
  n1.times do |i|
    n3.times do |j|
      n2.times do |k|
        res[i * n3 + j] += a[i * n2 + k] * b[k * n3 + j]
      end
    end
  end
end


def inner_block_multiply_non_parallel(a, b, res, i, n2, n3, offset, block_size)
  q2 = (n2.to_f / block_size).ceil
  q3 = (n3.to_f / block_size).ceil
  q3.times do |j1|
    q2.times do |k1|
      [n3 - j1 * block_size, block_size].min&.times do |j2|
        j = j1 * block_size + j2
        [n2 - k1 * block_size, block_size].min&.times do |k2|
          k = k1 * block_size + k2
          res[j] += a[i * n2 + k + offset] * b[k * n3 + j]
        end
      end
    end
  end
end

def block_multiply_non_parallel(a, b, res, n1, n2, n3, block_size)
  q1 = (n1.to_f / block_size).ceil
  q2 = (n2.to_f / block_size).ceil
  q3 = (n3.to_f / block_size).ceil
  q1.times do |i1|
    q3.times do |j1|
      q2.times do |k1|
        [n1 - i1 * block_size, block_size].min&.times do |i2|
          i = i1 * block_size + i2
          [n3 - j1 * block_size, block_size].min&.times do |j2|
            j = j1 * block_size + j2
            [n2 - k1 * block_size, block_size].min&.times do |k2|
              k = k1 * block_size + k2
              res[i * n3 + j] += a[i * n2 + k] * b[k * n3 + j]
            end
          end
        end
      end
    end
  end
end

if __FILE__ == $0
  # for i in 1 2 3 4; do mpirun -np $i ruby main.rb; done
  [[67, 125, 253], [64, 128, 256], [300, 200, 150], [256, 256, 128]].each do |sizes|
    n1, n2, n3 = sizes
    a = generate_random_matrix(n1, n2)
    b = generate_random_matrix(n2, n3)
    c = generate_res_matrix(n1, n3)
    test = Benchmark.bm do |x|
      x.report([n1, n2, n3, -1, 0].join(';')) { Matrix.build(n1, n2) { |row, col| a[n2 * row + col] } * Matrix.build(n2, n3) { |row, col| b[n3 * row + col] } }
      x.report([n1, n2, n3, 0, 0].join(';')) { point_multiply(a, b, c, n1, n2, n3) }
      x.report([n1, n2, n3, 1, 0].join(';')) { point_multiply(a, b, c, n1, n2, n3, :outer) }
      x.report([n1, n2, n3, 2, 0].join(';')) { point_multiply(a, b, c, n1, n2, n3, :inner) }
    end
    File.open("#{__dir__}/test.csv", 'a+') do |f|
      test.each do |bnch|
        f.puts "#{SIZE};#{bnch.label};#{bnch.real}"
      end
    end if RANK == 0
    [2, 20, (50..100).step(5).to_a, 200].flatten.each do |bs|
      test = Benchmark.bm do |x|
        x.report([n1, n2, n3, 0, bs].join(';')) { block_multiply(a, b, c, n1, n2, n3, bs) }
        x.report([n1, n2, n3, 1, bs].join(';')) { block_multiply(a, b, c, n1, n2, n3, bs, :outer) }
        x.report([n1, n2, n3, 2, bs].join(';')) { block_multiply(a, b, c, n1, n2, n3, bs, :inner) }
      end
      File.open("#{__dir__}/test.csv", 'a+') do |f|
        test.each do |bnch|
          f.puts "#{SIZE};#{bnch.label};#{bnch.real}"
        end
      end if RANK == 0
    end
  end
  # n1, n2, n3 = [10, 20, 56]
  # a = generate_random_matrix(n1, n2)
  # b = generate_random_matrix(n2, n3)
  # c = generate_res_matrix(n1, n3)
  # # point_multiply(a, b, c, n1, n2, n3)
  # if RANK == 0
  #   # p a.to_a
  #   # p b.to_a
  #   # p c.to_a
  #   p (Matrix.build(n1, n2) { |row, col| a[n2 * row + col] } * Matrix.build(n2, n3) { |row, col| b[n3 * row + col] }).to_a
  #   # p (Matrix.build(n1, n2) { |row, col| a[n2 * row + col] } * Matrix.build(n2, n3) { |row, col| b[n3 * row + col] }).to_a.flatten == c.to_a
  # end
  # gets
  MPI.Finalize
end
