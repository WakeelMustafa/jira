module Jira
  class Issue < ApplicationRecord
    belongs_to :project
    belongs_to :jira_user, optional: true
    belongs_to :code_giant_user, optional: true
    has_many :comments, dependent: :destroy
    has_many :histories, dependent: :destroy
  end
end