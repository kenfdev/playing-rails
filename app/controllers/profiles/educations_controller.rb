# typed: false

class Profiles::EducationsController < ApplicationController
  before_action :load_profile

  def create
    @education = @profile.educations.build(education_params)
    authorize @education
    if @education.save
      redirect_to edit_profile_path, notice: "Education added."
    else
      @new_education = @education
      render template: "profiles/edit", status: :unprocessable_entity
    end
  end

  def update
    @education = @profile.educations.find(params[:id])
    authorize @education
    if @education.update(education_params)
      redirect_to edit_profile_path, notice: "Education updated."
    else
      @errored_education = @education
      render template: "profiles/edit", status: :unprocessable_entity
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
    @profile = Current.user.profile || Current.user.build_profile
  end

  def education_params
    params.expect(education: %i[school degree field start_date end_date])
  end
end
