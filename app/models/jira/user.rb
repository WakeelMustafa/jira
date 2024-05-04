module Jira
  class User < ApplicationRecord
    has_many :issues, dependent: :nullify
  end
end