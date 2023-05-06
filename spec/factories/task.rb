FactoryBot.define do
  factory :task do
    association :user
    sequence(:title) { |n| "task#{n}" }
    sequence(:content) { |n| "content#{n}" }
    # todo: statusは0-3をランダムに生成したい。
    status { 0 }
    # todo: start_dateとend_dateをランダムに生成したい。
    start_date { "2023-05-01" }
    end_date { "2023-05-02" }
  end
end