class Tile
  attr_reader :bomb_count, :position

  def initialize(position, board, bomb = false)
    @bomb = bomb
    @flagged = false #delete?
    @revealed = false #delete?
    @position = position
    @board = board
    @bomb_count = 0
  end

  def adjacent_tiles
    adjacent_tiles = []
    directions = [[1, 1], [0, 1], 
                  [1, 0], [1, -1],
                  [0, -1], [-1, 1], 
                  [-1, 0], [-1, -1]]

    directions.each do |direction|
      adjacent_position = adjacent_tile(direction)
      if @board.on_board?(adjacent_position)
        adjacent_tiles << @board[adjacent_position]
      end
    end

    adjacent_tiles
  end
  
  def adjacent_tile(direction)
    current_x, current_y = self.position.first, self.position.last
    x_change, y_change = direction.first, direction.last
    
    [current_x + x_change, current_y + y_change]
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
    return '*'.colorize(:red) if bomb
    return '-'.colorize(:white) if @bomb_count == 0
    return @bomb_count.to_s.colorize(colors[@bomb_count]) if @bomb_count > 0
  end
  
  def toggle_flag
    @flagged = !@flagged
  end
  
end