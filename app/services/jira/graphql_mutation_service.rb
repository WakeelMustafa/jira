require 'httparty'
module Jira
  class GraphqlMutationService
    include HTTParty
    base_uri 'https://codegiant.io/graphql'

    def initialize(token)
      @headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{token}"
      }
    end

    def create_project(workspace_id:, project_type:, tracking_type:, prefix:, title:)
      query = <<~GRAPHQL
        mutation createProject($workspaceId: ID!, $projectType: String!, $trackingType: String!, $prefix: String!, $title: String!) {
          createProject(workspaceId: $workspaceId, projectType: $projectType, trackingType: $trackingType, prefix: $prefix, title: $title) {
            id
            title
          }
        }
      GRAPHQL
      variables = { workspaceId: workspace_id, projectType: project_type, trackingType: tracking_type, prefix: prefix, title: title }
      execute_query(query, variables)
    end

    def create_project_task(project_id:, title:, description:, estimated_time:, actual_time:, start_date:, due_date:)
      query = <<~GRAPHQL
        mutation createProjectTask($projectId: ID!, $title: String!, $description: String!, $estimatedTime: Float!, $actualTime: Float!, $startDate: String, $dueDate: String) {
          createProjectTask(projectId: $projectId, title: $title, description: $description, estimatedTime: $estimatedTime, actualTime: $actualTime, startDate: $startDate, dueDate: $dueDate) {
            id
            title
          }
        }
      GRAPHQL

      variables = {
        projectId: project_id,
        title: title,
        description: description,
        estimatedTime: estimated_time,
        actualTime: actual_time,
        startDate: start_date,
        dueDate: due_date
      }

      execute_query(query, variables)
    end

    def update_project_task(id:, assigned_user_id:)
      query = <<~GRAPHQL
        mutation updateProjectTask($id: ID!, $assignedUserId: ID) {
          updateProjectTask(id: $id, assignedUserId: $assignedUserId) {
            id
            title
          }
        }
      GRAPHQL
      variables = { id: id, assignedUserId: assigned_user_id }
      execute_query(query, variables)
    end

    def create_project_comment(task_id:, content:)
      query = <<~GRAPHQL
        mutation createProjectComment($taskId: ID!, $content: String!) {
          createProjectComment(taskId: $taskId, content: $content) {
            id
            # Other fields you may want to retrieve after creating the comment
          }
        }
      GRAPHQL
      variables = { taskId: task_id, content: content }
      execute_query(query, variables)
    end

    private

    def execute_query(query, variables = {})
      response = self.class.post("/", {
        body: { query: query, variables: variables }.to_json,
        headers: @headers
      })

      # Check if the response was successful and contains data
      if response.success?
        if response.parsed_response["errors"]
          # If there are GraphQL errors, return them
          { "errors" => response.parsed_response["errors"].map { |e| e["message"] }.join(", ") }
        else
          response.parsed_response["data"]
        end
      else
        # Handle HTTP errors
        { "errors" => "HTTP Error: #{response.code}" }
      end

      rescue HTTParty::Error => e
        { "errors" => "HTTParty Error: #{e.message}" }
      rescue StandardError => e
        { "errors" => "Standard Error: #{e.message}" }
    end
  end
end