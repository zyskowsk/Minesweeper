class Tile
  attr_reader :bomb_count, :pos, :bomb
  alias :bomb? :bomb
  
  DIRECTIONS = [[1, 1], 
                [0, 1], 
                [1, 0], 
                [1, -1],
                [0, -1],
                [-1, 1], 
                [-1, 0],
                [-1, -1]]
  

  def initialize(pos, board, bomb = false)
    @bomb, @board, @pos = bomb, board, pos
    @flagged, @revealed = false, false 
    @bomb_count = 0
  end

  def adjacent_positions
    DIRECTIONS.map do |(dx, dy)|
      [@pos[0] + dx, @pos[1] + dy]
    end.select do |pos|
      @board.on_board?(pos)
    end
  end
  
  def adjacent_tiles
    adjacent_positions.map { |pos| @board[pos] }
  end
  
  def calculate_bomb_count
    self.adjacent_tiles.each do |neighbor|
      @bomb_count += 1 if neighbor.bomb?
    end
  end
  
  def flagged?
    @flagged
  end
  
  def reveal
    @revealed = true
  end

  def revealed?
    @revealed
  end
  
  def hidden?
    !@revealed
  end

  def to_s
    colors = {1 => :light_green,
              2 => :light_yellow,
              3 => :light_magenta,
              4 => :magenta}
    return '*'.colorize(:red) if bomb?
    return '-'.colorize(:white) if @bomb_count == 0
    return @bomb_count.to_s.colorize(colors[@bomb_count]) if @bomb_count > 0
  end
  
  def toggle_flag
    @flagged = !@flagged
  end
  
end