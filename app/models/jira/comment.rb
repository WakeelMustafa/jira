# app/models/comment.rb
module Jira
  class Comment < ApplicationRecord
    belongs_to :issue
  end
end