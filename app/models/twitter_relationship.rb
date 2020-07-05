# frozen_string_literal: true

class TwitterRelationship < ApplicationRecord
  belongs_to :followed, class_name: 'TwitterUser'
  belongs_to :follower, class_name: 'TwitterUser'

  validates :followed, presence: true
  validates :follower, presence: true
end
