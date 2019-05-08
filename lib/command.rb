module Command
  # メソッドコメントを記述
  # 標準出力のクリアを行う
  def self.clear_stdout
    puts "\e[H\e[2J"
    puts "\e[H\e[2J"
  end

  # キー押下を促すメッセージを表示し、
  # キー押下時に標準出力をクリアする
  def self.press_enter
    puts "Press Enter Key..."
    gets
    clear_stdout
  end 
end
