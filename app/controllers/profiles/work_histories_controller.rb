# typed: false

class Profiles::WorkHistoriesController < ApplicationController
  before_action :load_profile

  def create
    @work_history = @profile.work_histories.build(work_history_params)
    authorize @work_history
    if @work_history.save
      redirect_to edit_profile_path, notice: "Work history added."
    else
      @new_work_history = @work_history
      render template: "profiles/edit", status: :unprocessable_entity
    end
  end

  def update
    @work_history = @profile.work_histories.find(params[:id])
    authorize @work_history
    if @work_history.update(work_history_params)
      redirect_to edit_profile_path, notice: "Work history updated."
    else
      @errored_work_history = @work_history
      render template: "profiles/edit", status: :unprocessable_entity
    end
  end

  def destroy
    @work_history = @profile.work_histories.find(params[:id])
    authorize @work_history
    @work_history.destroy
    redirect_to edit_profile_path, notice: "Work history removed."
  end

  private

  def load_profile
    @profile = Current.user.profile || Current.user.build_profile
  end

  def work_history_params
    params.expect(work_history: %i[company title start_date end_date description])
  end
end
