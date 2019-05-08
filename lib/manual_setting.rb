require './lib/command.rb'
require './config/initializer.rb'

module ManualSetting
  # TODO 他で定義されているメソッドを読み込む必要あり
  # 掃除担当手動設定時の担当者変更速度を変更する
  include Command
  include Initializer

  def speed_change
    message = ""
    loop do
      puts "速度変更"
      puts ""
      puts "　1～5:速度を変更する(1[←速い]～[遅い→]5)"
      puts "　9:戻る"
      puts "メニューを選択して下さい:"
      puts message
      message = ""
      input = gets.chomp
      case input
      when "1","2","3","4","5"
        @speed = Initializer::SPEED_LIST[input.to_i-1]
        puts "速度が#{input}に設定されました"
        Command.press_enter
        break
      when "9"
        Command.clear_stdout
        break
      else
        Command.clear_stdout
        message = "正しい値を入力して下さい"
        next
      end
    end
  end
end
