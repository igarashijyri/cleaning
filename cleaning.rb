require 'pry'
require 'date'
require './config/initializer.rb'
require './lib/manual_setting.rb'
require './lib/command.rb'
require './app/output.rb'

# TODO モジュール化・クラス分け・定数化・設定ファイル使用等、より良い書き方にする必要あり。

# クラスコメントを記述
# CleaningManagerは掃除担当を管理するクラスである。

class CleaningManager
  include Initializer
  include Command
  include ManualSetting
  include Output

  # アプリ起動準備メッセージを表示する
  # パラメータの秒数だけカウントダウンメッセージを表示する
  # @param  [Integer] 起動準備の待機秒数
  def prepare_run(num)
    num.times { |n|
      4.times { |i|
        Command.clear_stdout
        puts "アプリを起動しています..."
        puts "しばらくお待ちください..."
        if i.even?
          puts "#{(num-n).to_s}."
        else
          puts "#{(num-n).to_s}"
        end
        sleep(0.25)
      }
    }
  end

  def run
    Command.clear_stdout
    puts "アプリの起動準備が完了しました"
    Command.press_enter
    message = ""
    loop do
      puts "メニュー"
      puts ""
      puts "　1:自動で掃除担当を決める"
      puts "　2:手動で掃除担当を決める"
      puts "　3:手動の速度を変える"
      puts "　9:終了"
      puts "メニューを選択して下さい:"
      puts message
      message = ""

      input = gets.chomp
      case input
      when "1"
        Command.clear_stdout
        auto
      when "2"
        Command.clear_stdout
        manual
      when "3"
        Command.clear_stdout
        speed_change
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

cleaning_manager = CleaningManager.new
Command.clear_stdout
cleaning_manager.prepare_run(2)
cleaning_manager.run
Command.clear_stdout
