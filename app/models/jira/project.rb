module Jira
  class Project < ApplicationRecord
    validates :user_id, presence: true
    belongs_to :user
    has_many :issues, dependent: :destroy
    has_one :field_mapping, dependent: :destroy
  end
end