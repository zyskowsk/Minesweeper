class Board
  def initialize
    @grid = (0...9).map { |row| [nil] * 9 }
  end

  def generate_bomb_positions
    all_positions = []
    bomb_positions = []

    (0...9).each do |i|
      (0...9).each do |j|
        all_positions << [i, j]
      end
    end

    bomb_positions = all_positions.sample(10)
  end
end

class Tile
  def initialize
    @bomb = false
    @flagged = false
    @revealed = false
    @position = nil
    @board = nil
  end


end