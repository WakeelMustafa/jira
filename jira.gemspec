require_relative "lib/jira/version"

Gem::Specification.new do |spec|
  spec.name        = "jira"
  spec.version     = Jira::VERSION
  spec.authors     = ["WakeelMustafa"]
  spec.email       = ["wakeelmustafa999@gmail.com"]
  spec.homepage    = "https://github.com/WakeelMustafa/jira"
  spec.summary     = "Summary of Jira."
  spec.description = "Description of Jira."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://github.com/WakeelMustafa/jira"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/WakeelMustafa/jira"
  spec.metadata["changelog_uri"] = "https://github.com/WakeelMustafa/jira"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3.2"
  spec.add_dependency('omniauth-atlassian-oauth2')
  spec.add_dependency('omniauth-rails_csrf_protection')
  spec.add_dependency('httparty')
  spec.add_dependency('sidekiq')
  spec.add_dependency('redis')
  spec.add_dependency('rest-client')
  spec.add_dependency('json')
  spec.add_dependency ('dotenv')
end
