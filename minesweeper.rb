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
      @board.toggle_flag(input[1..-1])
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
        self[pos] = Tile.new(true, pos, self)
      else
        self[pos] = Tile.new(false, pos, self)
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

  def toggle_flag(pos)
    tile = self[pos]
    tile.flagged? ? tile.remove_flag : tile.flag
  end

  def won?
    (all_positions - @bomb_positions).all? do |pos|
      self[pos].revealed?
    end
  end
end

# class Tile
#   attr_reader :bomb_count, :position
#   attr_accessor :bomb, :revealed
# 
#   def initialize(bomb = false, position, board)
#     @bomb = bomb
#     @flagged = false #delete?
#     @revealed = false #delete?
#     @position = position
#     @board = board
#     @bomb_count = 0
#   end
# 
#   # Refactor later
#   def adjacent_tiles
#     directions = [[1, 1], [0, 1], [1, 0], [1, -1],
#                   [0, -1], [-1, 1], [-1, 0], [-1, -1]]
#     adjacent_tiles = []
#     current_x = self.position.first
#     current_y = self.position.last
# 
#     directions.each do |pos|
#       x = pos.first
#       y = pos.last
# 
#       new_pos = [current_x + x, current_y + y]
# 
#       if @board.on_board?(new_pos)
#         adjacent_tiles << @board[[current_x + x, current_y + y]]
#       end
#     end
# 
#     adjacent_tiles
#   end
#   
#   def bomb?
#     @bomb
#   end
#   
#   def calculate_bomb_count
#     self.adjacent_tiles.each do |neighbor|
#       @bomb_count += 1 if neighbor.bomb?
#     end
#   end
# 
#   def flag
#     @flagged = true
#   end
# 
#   def flagged?
#     @flagged
#   end
# 
#   def remove_flag
#     @flagged = false
#   end
# 
#   def revealed?
#     @revealed
#   end
# 
#   def reveal
#     @revealed = true
#   end
# 
#   def to_s
#     bomb? ? '*' : @bomb_count.to_s
#   end
# 
# 
# end