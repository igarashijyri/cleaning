require 'date'
require './config/initializer.rb'
require './lib/manual_setting.rb'

# TODO モジュール化・クラス分け・定数化・設定ファイル使用等、より良い書き方にする必要あり。

# クラスコメントを記述
# CleaningManagerは掃除担当を管理するクラスである。
#
# SAMPLE
# cleaning_manager = CleaningManager.new()
# cleaning_manager.run
# 
class CleaningManager

  # メソッドコメントを記述
  # 標準出力のクリアを行う
  def clear_stdout
    puts "\e[H\e[2J"
    puts "\e[H\e[2J"
  end

  # キー押下を促すメッセージを表示し、
  # キー押下時に標準出力をクリアする
  def press_enter
    puts "Press Enter Key..."
    gets
    clear_stdout
  end

  # アプリ起動準備メッセージを表示する
  # パラメータの秒数だけカウントダウンメッセージを表示する
  # @param  [Integer] 起動準備の待機秒数
  def prepare_run(num)
    num.times { |n|
      4.times { |i|
        clear_stdout
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

  # 掃除担当および確定済みの担当者を表示する。
  # また、未確定の担当者を順番に表示する。
  def show
    if !@fixed_men
      @fixed_men = true
      members = @men
      @members.concat(@men)
    elsif !@fixed_women
      @fixed_women = true
      members = @women
      @members.concat(@women)
    else
      members = @members
    end
    loop do
      members.each do |member|
        @member = member
        show_duty
        puts @member
        puts ""
        puts "Press Enter Key..."
        sleep(@speed)
      end
    end
  end

  # 掃除担当および確定済みの担当者を表示する。
  def show_duty
      clear_stdout
      puts "　当番を埋めていきます:"
      @cleaning_duty.each_with_index do |duty, i|
        print duty
        member = @current_members[i]
        puts member
        @done_members.push(member).uniq!
      end
      surplus_members = @current_members.reject{|mem| @done_members.include?(mem)}
      unless surplus_members.empty? || @current_members.size < @cleaning_duty.size
        print "　余り　　　　:"
        puts surplus_members.join(", ")
      end
      puts ""
  end

  # 掃除担当および確定済みの担当者をファイルへ出力する。
  def file_output(msg)
    file_name = Date.today
    data_time = DateTime.now
    puts "出力中..."
    sleep(1)
    begin
      File.open("#{file_name}.txt", "a:UTF-8") do |f|
        f.puts
        f.print(data_time.hour, "時", data_time.min, "分", data_time.sec, "秒 ", data_time.zone, "/#{msg}/#{@speed}")
        f.puts
        @cleaning_duty.each do |duty|
          f.print duty
          f.puts @current_members.shift
        end
        unless @current_members.empty?
          f.print "　余り　　　　:"
          f.puts @current_members.join(", ")
        end
        puts "出力に成功しました"
        sleep(2)
      end
    # 例外は小さい単位で捕捉すること
    rescue SystemCallError => e
      puts "出力に失敗しました"
      puts "class=[#{e.class}] message=[#{e.message}]"
    rescue IOError => e
      puts "出力に失敗しました"
      puts "class=[#{e.class}] message=[#{e.message}]"
      sleep(2)
    end
  end

  # 掃除担当を手動で確定する。
  def manual
    reset_members
    loop do
      # 画面表示とユーザ入力を並列処理で実行する
      thread = Thread.new do
        # 手動担当者選択表示を行う
        show
      end
      # ユーザ入力を受け取る
      while line = gets
        # 担当者の確定を行う
        @current_members.push(@member)
        @members.delete(@member)
        if @members.size == 1 || @current_members.size >= @cleaning_duty.size
          @current_members.concat(@members)
          @members.clear
        end
        # 担当者選択表示を停止する
        Thread::kill(thread) 
        show_duty
        puts @member unless @members.empty?
        puts ""
        puts "Press Enter Key..." unless @members.empty?
        @member = ""
        break
      end
      # 確定した担当者一覧をファイルに出力する
      if @members.size <= 0
        file_output("手動")
        press_enter
        break
      end
      gets
    end
  end

  # 掃除担当を自動で確定する。
  def auto
    reset_members
    
    if !@fixed_men
      @fixed_men = true
      member = @men.sample
      @current_members.push(member)
      @members.concat(@men).delete(member)
    end
    if !@fixed_women
      @fixed_women = true
      member = @women.sample
      @current_members.push(member)
      @members.concat(@women).delete(member)
    end
    
    @current_members.concat(@members.shuffle)
    show_duty
    file_output("自動")
    press_enter
  end

=begin
  # 掃除担当手動設定時の担当者変更速度を変更する
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
        @speed = @speed_list[input.to_i-1]
        puts "速度が#{input}に設定されました"
        press_enter
        break
      when "9"
        clear_stdout
        break
      else
        clear_stdout
        message = "正しい値を入力して下さい"
        next
      end
    end
  end
=end

  def run
    clear_stdout
    puts "アプリの起動準備が完了しました"
    press_enter
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
        clear_stdout
        auto
      when "2"
        clear_stdout
        manual
      when "3"
        clear_stdout
        Manual_setting.speed_change
      when "9"
        clear_stdout
        break
      else
        clear_stdout
        message = "正しい値を入力して下さい"
        next
      end
    end
  end
end

Initializer.new()
cleaning_manager = CleaningManager.new()
cleaning_manager.clear_stdout
cleaning_manager.prepare_run(2)
cleaning_manager.run
cleaning_manager.clear_stdout
