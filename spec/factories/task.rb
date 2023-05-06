FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "task#{n}" }
    sequence(:content) { |n| "content#{n}" }
    # todo: statusは0-3をランダムに生成したい。
    status { 0 }
    start_date { Time.zone.now }
    end_date { Time.zone.now + 1.day }
    association :user
  end
end