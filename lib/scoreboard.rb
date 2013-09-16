class ScoreBoard
  attr_reader :high_scores
  
  def initialize
    @high_scores = []
  end
  
  def add_score(time)
    puts "Congratulations!  You got a high score! What is your name?"
    name = gets.chomp
    @high_scores << [time.round(2), name]
    @high_scores.sort_by! { |pair| pair.first }
    puts self
    save
  end
  
  def to_s
    score_string = ""
    score_string += "High Score List\n" + ("_" * 20) + "\n"
    @high_scores.each do |score|
      score_string +=  "#{score.first} seconds : #{score.last}\n"
    end
    
    score_string
  end
  
  private
    def save
      File.open('../high_scores', 'w') do |f|
        f.puts self.to_yaml
      end
    end
end