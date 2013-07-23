require 'yaml'
load './tile.rb'

class Minesweeper
  attr_reader :board

  def initialize
    @board = Board.new
  end

  def click_square(pos)
    if @board[pos].bomb?
      @board.reveal_all
      puts "You lost!"
      puts @board
    elsif @board.won?
      puts "yay."
      @board.reveal_all
      puts @board
    else
      @board.reveal_neighbors(pos)
    end
  end

  def play
    puts "Welcome to Minesweeper!"
    puts "To save your game, enter 'save.'"

    until @board.won?
      puts @board
      puts "What square do you want to reveal?"
      puts "Or type 'F x y' to flag a position."
      input = get_input

      if input.first.to_s.downcase == 'save'
        save_game(input.last)
        puts "Game saved!"
        return
      end

      play_turn(input)
    end
  end

  def get_input
    input = gets.chomp.split(' ')
    return input if input.first.downcase == 'save'

    pos = input.map(&:to_i)
    coordinates = pos[-2..-1]
    while !(2..3).include?(pos.length) || @board[coordinates].revealed? ||
      !@board.on_board?(coordinates)
      puts "Not a valid move; please try again!"
      pos = gets.chomp.split(' ').map(&:to_i)
      coordinates = pos[-2..-1]
    end

    pos
  end

  def self.load(file)
    file_contents = File.read(file)

    game = YAML.load(file_contents)
    game.play
  end

  def play_turn(input)

    if input.length == 2
      click_square(input)
    else
      @board[input[1..-1]].toggle_flag
    end
  end

  def save_game(file)
    File.open(file, 'w') do |f|
      f.puts self.to_yaml
    end
  end
end

# This is a minesweeper game for command line
class Board
  def initialize
    @grid = (0...9).map { |row| [nil] * 9 }
    @bomb_positions = bomb_positions
    populate_grid
  end

  def [](pos)
    @grid[pos.first][pos.last]
  end

  def []=(pos, tile)
    @grid[pos.first][pos.last] = tile
  end

  def all_positions
    all_positions = []

    (0...9).each do |i|
      (0...9).each do |j|
        all_positions << [i, j]
      end
    end

    all_positions
  end
  
  def bomb_positions
    all_positions.sample(10)
  end

  def on_board?(pos)
    (0...9).include?(pos.first) && (0...9).include?(pos.last)
  end

  # Refactor
  def populate_grid
    all_positions.each do |pos|
      if @bomb_positions.include?(pos)
        self[pos] = Tile.new(pos, self, true)
      else
        self[pos] = Tile.new(pos, self, false)
      end
    end

    all_positions.each do |pos|
      self[pos].calculate_bomb_count
    end
  end

  def reveal_all
    all_positions.each do |pos|
      self[pos].reveal
    end
  end

  # Where should this be?
  def reveal_neighbors(pos)
    unless self[pos].bomb_count == 0
      self[pos].reveal
      return
    end
    self[pos].reveal
    self[pos].adjacent_tiles.each do |neighbor|
      next if neighbor.revealed?
      reveal_neighbors(neighbor.position)
    end
  end

  # this is bad form, p in to_s method
  def to_s
    new_board = @grid.dup.map do |row|
       row.map do |elem|
        if elem.revealed?
          elem.to_s
        elsif elem.flagged?
          "F"
        else
           "#"
        end
      end
    end

    new_board.each do |row|
      p row
    end
  end

  def won?
    (all_positions - @bomb_positions).all? do |pos|
      self[pos].revealed?
    end
  end
end