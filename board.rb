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
  
  def add_bomb_count
    all_positions.each do |pos|
      self[pos].calculate_bomb_count
    end
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
  
  def place_tile(pos)
    if @bomb_positions.include?(pos)
      self[pos] = Tile.new(pos, self, true)
    else
      self[pos] = Tile.new(pos, self, false)
    end
  end

  def populate_grid
    all_positions.each do |pos|
      place_tile(pos)
    end
    
    add_bomb_count
  end

  def reveal_all
    all_positions.each do |pos|
      self[pos].reveal
    end
  end

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

  def rows_string
    rows_string = ""
    
    stringify_tiles.each_with_index do |row, i|
      rows_string += "#{i} ".colorize(:cyan) + row.join(" ") + "\n"
    end
    
    rows_string  
  end
  
  def stringify_tiles
    @grid.dup.map do |row|
       row.map do |elem|
        if elem.revealed?
          elem.to_s
        elsif elem.flagged?
          "F".colorize(:red)
        else
          "▨"
        end
      end
    end
  end

  def to_s
    top_row_string + rows_string
  end
  
  def top_row_string
    top_row = ""
    (0...9).each do |i|
      top_row += " #{i}".colorize(:cyan) 
    end
    
    " " + top_row + "\n"
  end

  def won?
    (all_positions - @bomb_positions).all? do |pos|
      self[pos].revealed?
    end
  end
end