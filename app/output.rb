module Output
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
    Command.clear_stdout
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
        Command.press_enter
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
    Command.press_enter
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

end
