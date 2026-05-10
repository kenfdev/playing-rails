# typed: false

class ProfilesController < ApplicationController
  before_action :load_profile

  def edit
    authorize @profile
  end

  def update
    authorize @profile
    if @profile.update(profile_params)
      redirect_to edit_profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_profile
    @profile = Current.user.profile || Current.user.create_profile!
  rescue ActiveRecord::RecordNotUnique
    @profile = Current.user.reload.profile
  end

  def profile_params
    params.expect(profile: %i[name headline bio])
  end
end
