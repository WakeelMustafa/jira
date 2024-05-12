module Jira
  class Project < ApplicationRecord
    self.table_name = 'projects'
    
    validates :user_id, presence: true
    belongs_to :user, class_name: 'Jira::User'
    has_many :issues, dependent: :destroy, class_name: 'Jira::Issue'
    has_one :field_mapping, dependent: :destroy, class_name: 'Jira::FieldMapping'
  end
end