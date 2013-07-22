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

  # this is bad form, p in to_s method
  def to_s
    new_board = @grid.dup.map do |row|
       row.map do |elem|
        elem.revealed? ? elem.to_s : "#"
      end
    end

    new_board.each do |row|
      p row
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

  def flagged?
    @flag
  end

  def revealed?
    @revealed
  end

  def to_s
    bomb? ? '*' : @bomb_count.to_s
  end


end