module Jira
  class CodeGiantUser < ApplicationRecord
    has_many :issues, dependent: :nullify
  end
end