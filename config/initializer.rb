 module Initializer
 # 初期化を行う
 HOGE = 123
  def initialize
    reset_members
    # 掃除の担当一覧
    @cleaning_duty = ["　モップ　　　:", "　掃除機　　　:", "　シンク　　　:"]
    male_toileting = "　トイレ(男性):"
    female_toileting = "　トイレ(女性):"
    @cleaning_duty.unshift(female_toileting) unless @women.empty?
    @cleaning_duty.unshift(male_toileting) unless @men.empty?
    # 手動設定時の担当者変更速度
    @speed_list = [0.01, 0.03, 0.08 ,0.2 ,0.5, 1.0]
    @speed = @speed_list[2]
  end

  # 担当者情報を初期化する
  def reset_members
    # 担当者一覧
    @members = []
    @men = ["男1", "男2", "男3", "男4"]
    @women = ["女1", "女2", "女3", "女4", "女5"]
    # 確定した担当者一覧
    @current_members = []
    @done_members = []
    @member = ""
    @fixed_men = @men.empty?
    @fixed_women = @women.empty?
    p "@fixed_men=#{@fixed_men}"
    p "@fixed_women=#{@fixed_women}"
  end
end
