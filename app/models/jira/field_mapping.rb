module Jira
  class FieldMapping < ApplicationRecord
    belongs_to :project
  end
end