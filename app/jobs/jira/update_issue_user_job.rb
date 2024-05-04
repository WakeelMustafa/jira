module Jira
  class UpdateIssueUserJob < ApplicationJob
    queue_as :default

    def perform(project, jira_user_ids, code_giant_user_ids)
      graphql_service = GraphqlMutationService.new("6Lx8ngqrE7tDV47xjsyA")
      id_to_graphql_id_mapping = CodeGiantUser.where(id: code_giant_user_ids).pluck(:id, :graphql_id).to_h

      unless project.code_giant_project_id.present?
        project_info = {
          workspace_id: "7489",
          project_type: "scrum",
          tracking_type: "time",
          prefix: project.prefix,
          title: project.codegiant_title
        }

        project_response = graphql_service.create_project(**project_info)

        if project_response.dig("createProject", "id")
          created_project_id = project_response["createProject"]["id"]
          project.update(code_giant_project_id: created_project_id)
        elsif project_response["errors"]
          error_messages = project_response["errors"].map { |error| error["message"] }.join(", ")
          Rails.logger.error "Failed to create project in CodeGiant: #{error_messages}"
          return
        else
          Rails.logger.error "Failed to create project in CodeGiant for an unknown reason."
          return
        end
      else
        created_project_id = project.code_giant_project_id
      end

      field_mappings = project&.field_mapping
      Issue.transaction do
        jira_user_ids.zip(code_giant_user_ids).each do |jira_user_id, code_giant_user_id|
          issues = Issue.where(jira_user_id: jira_user_id)

          issues.each do |issue|
            issue.update(code_giant_user_id: code_giant_user_id)

            if issue.code_giant_task_id.blank?
              # Prepare task info
              task_info = {
                project_id: created_project_id,
                title: issue.public_send(field_mappings&.mapping&.fetch('Title', :summary) || :summary),
                estimated_time: issue.public_send(field_mappings&.mapping&.fetch('Estimated Time', :estimated_time) ||  :estimated_time).to_f/3600,
                actual_time: issue.public_send(field_mappings&.mapping&.fetch('Actual Time', :actual_time) || :actual_time).to_f/3600,
                start_date: issue.public_send(field_mappings&.mapping&.fetch('Start Date', :jira_created_at) || :jira_created_at),
                due_date: issue.public_send(field_mappings&.mapping&.fetch('Due Date', :due_date) || :due_date)
              }

              # Handle the description field based on the mapping
              description_fields = field_mappings&.mapping&.fetch('Description', [:description])
              description_values = description_fields&.map do |field|
                "#{field}: #{issue.public_send(field)}"
              end&.join("\n")

              task_info[:description] = description_values || ''

              # Call to create a project task with task_info
              task_response = graphql_service.create_project_task(**task_info)

              if task_response["createProjectTask"] && task_response["createProjectTask"]["id"]
                created_task_id = task_response["createProjectTask"]["id"]
                issue.update(code_giant_task_id: created_task_id)
                create_comments_for_issue(issue, graphql_service, created_task_id)
              else
                Rails.logger.error "Failed to create task for issue #{issue.id} in CodeGiant"
              end
            end

            # Always update the task with the assigned user ID if code_giant_task_id is present
            if issue.code_giant_task_id.present?
              code_giant_user_graphql_id = id_to_graphql_id_mapping[code_giant_user_id.to_i]

              task_update_info = {
                id: issue.code_giant_task_id,
                assigned_user_id: code_giant_user_graphql_id
              }
              update_response = graphql_service.update_project_task(**task_update_info)
              unless update_response.dig("updateProjectTask", "id")
                Rails.logger.error "Failed to update task #{issue.code_giant_task_id} in CodeGiant"
              end
            end
          end
        end
      end
      flash_message = "Tasks created and user mapping updated successfully."
    end
  
    private
    
    def create_comments_for_issue(issue, graphql_service, created_task_id)
      issue&.comments.each do |comment|
        comment_info = {
          task_id: created_task_id,
          content: comment&.body
        }
        comment_response = graphql_service.create_project_comment(**comment_info)

        if comment_response["createProjectComment"] && comment_response["createProjectComment"]["id"]
          # Handle successful comment creation
          Rails.logger.info "Comment created successfully for task #{created_task_id}"
        else
          # Handle comment creation failure
          Rails.logger.error "Failed to create comment for task #{created_task_id}"
        end
      end
    end
  end
end