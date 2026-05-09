# typed: false

class Admin::SmokeController < ApplicationController
  before_action :require_authentication

  def show
    authorize :smoke, :show?
  end

  def enqueue
    authorize :smoke, :enqueue?
    SmokeJob.perform_later(Current.user.id)
    redirect_to admin_smoke_path, notice: "Smoke job enqueued."
  end
end
