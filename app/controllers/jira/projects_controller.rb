module Jira
  class ProjectsController < ApplicationController
    before_action :authenticate_user!, only: %i[index fetch_latest_projects]
    before_action :set_project, only: %i[show fetch_issues update_issue_user]
    skip_before_action :verify_authenticity_token, only: %i[fetch_issues update_importing_project fetch_codegiant_users]

    def index
      @projects = current_user.projects.all
    end

    def show
    end

    def fetch_latest_projects
      flash_message = FetchJiraProjectsJob.perform_now(current_user)
      flash[:notice] = flash_message if flash_message.present?
      redirect_to projects_path
    end

    def fetch_issues
      FetchJiraIssuesJob.perform_now(current_user, @project&.project_id, params[:id])
    end

    def edit_importing_project
      @project = Project.find(params[:project_id])
    end

    def update_importing_project
      @project = Project.find(params[:project][:project_id])
      @project.update(codegiant_title: params[:project][:codegiant_title], prefix: params[:project][:prefix])
      flash[:notice] = 'Project was updated successfully.'
      redirect_to @project
    end

    def fetch_codegiant_users
      FetchCodegiantUsersJob.perform_now()
    end

    def codegiant_users_page
      @jira_users = JiraUser.joins(:issues).where(issues: { project_id: params[:project_id] }).distinct
      @code_giant_users = CodeGiantUser.all
    end

    def update_issue_user
      flash_message = UpdateIssueUserJob.perform_now(@project, params[:jira_user_ids], params[:code_giant_user_ids])
      flash[:notice] = flash_message if flash_message.present?
      redirect_to request.referer
    rescue => e
      redirect_to request.referer, alert: "An unexpected error occurred: #{e.message}"
    end

    def destroy
      @project = Project.find(params[:id])
      @project.destroy
      flash[:notice] = 'Project was successfully deleted.'
      redirect_to projects_path
    end

    private

    def authenticate_user!
      unless session[:user_id]
        flash[:alert] = "You must be logged in to access this page."
        redirect_to root_path
      end
    end

    def set_project
      @project = current_user.projects.find(params[:id])
    end
  end
end