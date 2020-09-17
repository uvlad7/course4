require 'pycall/import'
require 'pry'
require 'ruby-progressbar'

class Vigenere
  # Encrypts text with given key. Doesn't change characters that are not included in alphabet
  # @param text [String] text for encryption
  # @param key [String]
  # @param alphabet [Integer, #pos, Boolean, #include?] pos should return position of character in alphabet
  def self.encrypt(text, key, alphabet)
    modify(text, key, alphabet, 1)
  end

  def self.decrypt(text, key, alphabet)
    modify(text, key, alphabet, -1)
  end

  private

  def self.modify(text, key, alphabet, magic_param)
    offset = key.chars.map! { |char| alphabet.pos_of(char) }.compact.map! { |i| i * magic_param }
    key_len = offset.length
    text.chars.map!.with_index do |char, index|
      alphabet.include?(char) ? alphabet.advance(char, offset[index % key_len]) : char
    end.join
  end
end

class Caesar
  def self.key(text_arr, alphabet)
    freq = text_arr.inject(Hash.new(0)) { |hash, char| char == ' ' ? hash : hash.merge!(char => hash[char] + 1) }
    size = freq.values.sum
    freq.transform_values! { |v| v.to_f / size }
    alphabet::FREQUENCIES.keys.map! do |k|
      offset = alphabet.pos_of(k)
      [k, alphabet::FREQUENCIES.map { |k, v| (freq[alphabet.advance(k, offset)] - v) ** 2 }.sum]
    end.min { |a, b| a.last <=> b.last }.first
  end
end

class Kasiski
  def self.frequencies(text, alphabet)
    result = {}
    n = 2
    pos_arr = (0..(text.length - n))
    while pos_arr && pos_arr.any?
      temp_result = Hash.new({ count: 0 })
      pos_arr.each do |i|
        gr = text[i...(i + n)]
        # next unless gr =~ /^\p{L}.*\p{L}$/
        temp_result[gr] = { count: temp_result[gr][:count] + 1, pos: (temp_result[gr][:pos] || []).push(i) }
      end
      temp_result.delete_if { |_key, value| value[:count] == 1 }
      # break if temp_result.empty?
      result.merge!(temp_result)
      pos_arr = temp_result.values.map! { |v| v[:pos] }.flatten!
      n += 1
    end
    result.delete_if { |key, _value| key[0] == ' ' || key[-1] == ' ' }
    result.map do |key, value|
      weight = Math.log(key.delete(' ').size)
      value[:pos].each_cons(2).map { |prev, cur| { value: cur - prev, weight: weight } }
    end.flatten.inject(Hash.new(0)) { |hash, dist| hash.merge!(dist[:value] => hash[dist[:value]] + dist[:weight]) }
  end

  def self.key_len(frequencies, threshold)
    freq_threshold = ((frequencies.values.max * threshold).to_f / 100).floor
    frequencies.reject { |_k, v| v < freq_threshold }.keys.reduce(&:gcd) || 1
  end

  def self.key(text, key_len, alphabet)
    text.chars.group_by.with_index { |c, i| i % key_len }.values.map! { |text_arr| Caesar.key(text_arr, alphabet) }.join
  end
end

class Russian
  FREQUENCIES = { 'А' => 0.07821, 'Б' => 0.01732, 'В' => 0.04491, 'Г' => 0.01698, 'Д' => 0.03103, 'Е' => 0.08567, 'Ё' => 0.0007, 'Ж' => 0.01082, 'З' => 0.01647, 'И' => 0.06777, 'Й' => 0.01041, 'К' => 0.03215, 'Л' => 0.04813, 'М' => 0.03139, 'Н' => 0.0685, 'О' => 0.11394, 'П' => 0.02754, 'Р' => 0.04234, 'С' => 0.05382, 'Т' => 0.06443, 'У' => 0.02882, 'Ф' => 0.00132, 'Х' => 0.00833, 'Ц' => 0.00333, 'Ч' => 0.01645, 'Ш' => 0.00775, 'Щ' => 0.00331, 'Ъ' => 0.00023, 'Ы' => 0.01854, 'Ь' => 0.02106, 'Э' => 0.0031, 'Ю' => 0.00544, 'Я' => 0.01979 }.freeze

  def self.include?(char)
    (1040..1103) === char.ord || char.ord == 1025 || char.ord == 1105
  end

  def self.pos_of(char)
    case pos = char.ord
    when (1040..1045)
      pos - 1040
    when (1072..1077)
      pos - 1072
    when 1025, 1105
      6
    when (1046..1071)
      pos - 1039
    when (1078..1103)
      pos - 1071
    else
      nil
    end
  end

  def self.advance(char, i)
    return nil unless include?(char)
    new_pos = (pos_of(char) + i) % 33
    is_upper = (1040..1071) === char.ord || char.ord == 1025
    case new_pos
    when (0..5)
      ((is_upper ? 1040 : 1072) + new_pos).chr(Encoding::UTF_8)
    when 6
      is_upper ? 'Ё' : 'ё'
    else
      ((is_upper ? 1039 : 1071) + new_pos).chr(Encoding::UTF_8)
    end
  end

  def self.size
    33
  end
end

class English
  FREQUENCIES = { 'A' => 0.08167, 'B' => 0.01492, 'C' => 0.02782, 'D' => 0.04253, 'E' => 0.12702, 'F' => 0.0228, 'G' => 0.02015, 'H' => 0.06094, 'I' => 0.06966, 'J' => 0.00153, 'K' => 0.00772, 'L' => 0.04025, 'M' => 0.02406, 'N' => 0.06749, 'O' => 0.07507, 'P' => 0.01929, 'Q' => 0.00095, 'R' => 0.05987, 'S' => 0.06327, 'T' => 0.09056, 'U' => 0.02758, 'V' => 0.00978, 'W' => 0.0236, 'X' => 0.0015, 'Y' => 0.01974, 'Z' => 0.00074 }.freeze

  def self.include?(char)
    (65..90) === char.ord || (97..122) === char.ord
  end

  def self.pos_of(char)
    case pos = char.ord
    when (65..90)
      pos - 65
    when (97..122)
      pos - 97
    else
      nil
    end
  end

  def self.advance(char, i)
    return nil unless include?(char)
    new_pos = (pos_of(char) + i) % 26
    is_upper = (65..90) === char.ord
    ((is_upper ? 65 : 97) + new_pos).chr(Encoding::UTF_8)
  end

  def self.size
    26
  end
end

class App
  include PyCall::Import

  def initialize
    pyfrom('matplotlib', import: :pyplot)
    pyfrom('mpl_toolkits.mplot3d', import: :axes3d)
    pyimport('numpy', as: :np)
    @en_text = File.read('./en.txt')
    @ru_text = File.read('./ru.txt')
  end

  def random_key(len, alphabet)
    str = alphabet == English ? @en_text : @ru_text
    arr = []
    while arr.size < len
      pos = rand(0...str.size)
      arr.push(str[pos].upcase) if alphabet.include?(str[pos])
    end
    arr.join
  end

  def text_piece(len, alphabet)
    str = alphabet == English ? @en_text : @ru_text
    start_pos = rand(0...(str.size - len))
    str[start_pos...(start_pos + len)].chars.map! do |char|
      alphabet.include?(char) ? char.upcase : ' '
    end.join
  end

  def run
    text_experiment(English, 5)
    key_experiment(English, 10_000)
    text_experiment(Russian, 5)
    key_experiment(Russian, 10_000)
  end

  def key_experiment(alphabet, text_len)
    thresholds = (5..100).step(5).to_a
    key_lens = [2, 3, 6, 10, 15, 20, 25, 35, 50, 100]

    result_data = Array.new(key_lens.size) { Array.new(thresholds.size) { 0 } }
    progressbar = ProgressBar.create(total: key_lens.size * thresholds.size * 10, title: "Key experiment: #{alphabet}", output: $stderr)
    key_lens.each_with_index do |key_len, i|
      10.times do
        key = random_key(key_len, alphabet)
        text = text_piece(text_len, alphabet)
        enc_text = Vigenere.encrypt(text, key, alphabet)
        frequencies = Kasiski.frequencies(enc_text, alphabet)
        thresholds.each_with_index do |threshold, j|
          result_data[i][j] += 1 if Vigenere.decrypt(enc_text, Kasiski.key(enc_text, Kasiski.key_len(frequencies, threshold), alphabet), alphabet) == text
          progressbar.increment
        end
      end
    end
    show_result(thresholds, key_lens, result_data, ['Threshold, %', 'Key len', 'Result'])
  end

  def text_experiment(alphabet, key_len)
    thresholds = (5..100).step(5).to_a
    text_lens = [200, 300, 600, 1000, 1500, 2000, 2500, 3500, 5000, 10000]

    result_data = Array.new(text_lens.size) { Array.new(thresholds.size) { 0 } }
    progressbar = ProgressBar.create(total: text_lens.size * thresholds.size * 10, title: "Text experiment: #{alphabet}", output: $stderr)
    text_lens.each_with_index do |text_len, i|
      10.times do
        key = random_key(key_len, alphabet)
        text = text_piece(text_len, alphabet)
        enc_text = Vigenere.encrypt(text, key, alphabet)
        frequencies = Kasiski.frequencies(enc_text, alphabet)
        thresholds.each_with_index do |threshold, j|
          result_data[i][j] += 1 if Vigenere.decrypt(enc_text, Kasiski.key(enc_text, Kasiski.key_len(frequencies, threshold), alphabet), alphabet) == text
          progressbar.increment
        end
      end
    end
    show_result(thresholds, text_lens, result_data, ['Threshold, %', 'Text len', 'Result'])
  end

  def show_result(thresholds, lens, result_data, labels)
    ax = pyplot.figure.add_subplot(111, projection: '3d')
    ax.set_xlabel(labels[0])
    ax.set_ylabel(labels[1])
    ax.set_zlabel(labels[2])

    xs, ys = np.meshgrid(np.array(thresholds), np.array(lens))
    ax.plot_wireframe(xs, ys, np.array(result_data), color: 'green')
    pyplot.show
  end
end

App.new.run
