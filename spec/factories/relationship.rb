# frozen_string_literal: true

FactoryBot.define do
  factory :relationship do
    association :follower, factory: :user
    association :following, factory: :user
  end
end
