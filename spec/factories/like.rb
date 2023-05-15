FactoryBot.define do
  factory :like do
    association :user
    association :task
  end
end