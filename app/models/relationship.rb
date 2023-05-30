# frozen_string_literal: true

class Relationship < ApplicationRecord
  belongs_to :following, class_name: 'User', optional: true
  belongs_to :follower, class_name: 'User', optional: true

  validates :following_id, presence: true
  validates :follower_id, presence: true
end
