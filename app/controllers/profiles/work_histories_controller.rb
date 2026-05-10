# typed: false

class Profiles::WorkHistoriesController < ApplicationController
  before_action :load_profile

  def create
    @work_history = @profile.work_histories.build(work_history_params)
    authorize @work_history
    if @work_history.save
      redirect_to edit_profile_path, notice: "Work history added."
    else
      redirect_to edit_profile_path, alert: error_message(@work_history)
    end
  end

  def update
    @work_history = @profile.work_histories.find(params[:id])
    authorize @work_history
    if @work_history.update(work_history_params)
      redirect_to edit_profile_path, notice: "Work history updated."
    else
      redirect_to edit_profile_path, alert: error_message(@work_history)
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
    @profile = Current.user.profile || Current.user.create_profile!
  end

  def work_history_params
    params.expect(work_history: %i[company title start_date end_date description])
  end

  def error_message(record)
    "Could not save work history: #{record.errors.full_messages.to_sentence}"
  end
end
