# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    association :task
    association :visitor, factory: :user
    association :visited, factory: :user
    action { '' }
    checked { false }
  end
end
