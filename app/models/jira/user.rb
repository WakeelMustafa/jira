module Jira
  class User < ApplicationRecord
    validates :email, presence: true, uniqueness: true
    validates :jira_uid, uniqueness: true
    has_many :projects, dependent: :destroy
    has_many :issues, through: :projects
  end
end