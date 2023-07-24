# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    avatar_url { 'https://your-s3-bucket-name.s3.amazonaws.com/sample_avatar.png' }
    bio { '' }
    sequence(:username) { |n| "test#{n}" }
    sequence(:nickname) { |n| "てすと#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password_digest { '' }
    firebase_id { '' }
  end
end
