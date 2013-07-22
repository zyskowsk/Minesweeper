class Minesweeper
  def initialize
    @board = Board.new
  end

  def play
    puts "Welcome to Minesweeper!"

    until @board.won?
      puts @board
      puts "What square do you want to reveal?"
      pos = gets.chomp.split(' ').map(&:to_i)
      if @board[pos].bomb?
        @board.reveal_all
        puts "You lost!"
        puts @board
      else
        @board.reveal_neighbors(pos)
      end
    end

    puts "yay."
    @board.reveal_all
    puts @board
  end

end

# This is a minesweeper game for command line
class Board
  def initialize
    @grid = (0...9).map { |row| [nil] * 9 }
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

  def place_flag(pos)
    @grid[pos].flag
  end

  # Refactor
  def populate_grid
    all_positions.each do |pos|
      if bomb_positions.include?(pos)
        self[pos] = Tile.new(true, pos, self)
      else
        self[pos] = Tile.new(false, pos, self)
      end
    end

    all_positions.each do |pos|
      self[pos].calculate_bomb_count
    end
  end

  def remove_flag(pos)
    @grid[pos].remove_flag
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
    (all_positions - bomb_positions).all? do |pos|
      self[pos].revealed?
    end
  end
end

class Tile
  attr_reader :bomb_count, :position
  attr_accessor :bomb

  def initialize(bomb = false, position, board)
    @bomb = bomb
    @flag = false #delete?
    @revealed = false #delete?
    @position = position
    @board = board
    @bomb_count = 0
  end

  # Refactor later
  def adjacent_tiles
    directions = [[1, 1], [0, 1], [1, 0], [1, -1],
                  [0, -1], [-1, 1], [-1, 0], [-1, -1]]
    adjacent_tiles = []
    current_x = self.position.first
    current_y = self.position.last

    directions.each do |pos|
      x = pos.first
      y = pos.last

      if (0...9).include?(current_x + x) && (0...9).include?(current_y + y)
        adjacent_tiles << @board[[current_x + x, current_y + y]]
      end
    end

    adjacent_tiles
  end

  def bomb?
    @bomb
  end

  def calculate_bomb_count
    self.adjacent_tiles.each do |neighbor|
      @bomb_count += 1 if neighbor.bomb?
    end
  end

  def flag
    @flagged = true
  end

  def flagged?
    @flag
  end

  def remove_flag
    @flagged = false
  end

  def revealed?
    @revealed
  end

  def reveal
    @revealed = true
  end

  def to_s
    bomb? ? '*' : @bomb_count.to_s
  end


end