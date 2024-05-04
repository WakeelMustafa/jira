module Jira
# app/models/history.rb
  class History < ApplicationRecord
    belongs_to :issue
  end
end