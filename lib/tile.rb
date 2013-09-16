class Tile
  attr_reader :bomb_count, :pos, :bomb, :flagged, :revealed
  alias_method :bomb?, :bomb
  alias_method :flagged?, :flagged
  alias_method :revealed?, :revealed
  
  DIRECTIONS = [ [1, 1], 
                 [0, 1], 
                 [1, 0], 
                 [1, -1],
                 [0, -1],
                 [-1, 1], 
                 [-1, 0],
                 [-1, -1] ]
                
  COLORS = { 1 => :light_green,
             2 => :light_yellow,
             3 => :light_magenta,
             4 => :magenta }
  

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
  
  def calculate_bomb_count
    adjacent_tiles.each do |neighbor|
      @bomb_count += 1 if neighbor.bomb?
    end
  end
  
  def hidden?
    not self.revealed?
  end

  def reveal
    @revealed = true
  end
  
  def toggle_flag
    @flagged = !@flagged
  end
  
  def to_s
    return '*'.colorize(:red) if bomb?
    return '-'.colorize(:white) if @bomb_count == 0
    return @bomb_count.to_s.colorize(COLORS[@bomb_count]) if @bomb_count > 0
  end
  
  def adjacent_tiles
    adjacent_positions.map { |pos| @board[pos] }
  end
end