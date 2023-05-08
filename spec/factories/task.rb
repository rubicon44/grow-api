FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "task#{n}" }
    sequence(:content) { |n| "content#{n}" }
    # todo: statusは0-3をランダムに生成したい。
    status { 0 }
    start_date { Time.zone.now.strftime('%Y-%m-%d') }
    end_date { (Time.zone.now + 1.day).strftime('%Y-%m-%d') }
    association :user
  end
end