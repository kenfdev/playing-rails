# typed: false

class Profiles::EducationsController < ApplicationController
  before_action :load_profile

  def create
    @education = @profile.educations.build(education_params)
    authorize @education
    if @education.save
      redirect_to edit_profile_path, notice: "Education added."
    else
      redirect_to edit_profile_path, alert: error_message(@education)
    end
  end

  def update
    @education = @profile.educations.find(params[:id])
    authorize @education
    if @education.update(education_params)
      redirect_to edit_profile_path, notice: "Education updated."
    else
      redirect_to edit_profile_path, alert: error_message(@education)
    end
  end

  def destroy
    @education = @profile.educations.find(params[:id])
    authorize @education
    @education.destroy
    redirect_to edit_profile_path, notice: "Education removed."
  end

  private

  def load_profile
    @profile = Current.user.profile || Current.user.create_profile!
  end

  def education_params
    params.expect(education: %i[school degree field start_date end_date])
  end

  def error_message(record)
    "Could not save education: #{record.errors.full_messages.to_sentence}"
  end
end
