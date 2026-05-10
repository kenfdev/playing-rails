# typed: false

class Profiles::SkillsController < ApplicationController
  before_action :load_profile

  def create
    @skill = @profile.skills.build(skill_params)
    authorize @skill
    if @skill.save
      redirect_to edit_profile_path, notice: "Skill added."
    else
      redirect_to edit_profile_path, alert: "Could not add skill: #{@skill.errors.full_messages.to_sentence}"
    end
  end

  def destroy
    @skill = @profile.skills.find(params[:id])
    authorize @skill
    @skill.destroy
    redirect_to edit_profile_path, notice: "Skill removed."
  end

  private

  def load_profile
    @profile = Current.user.profile || Current.user.create_profile!
  end

  def skill_params
    params.expect(skill: %i[name])
  end
end
