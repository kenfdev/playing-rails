# typed: false

class Profiles::SalariesController < ApplicationController
  before_action :load_salary

  def edit
    authorize @salary
  end

  def update
    authorize @salary
    if @salary.update(salary_params)
      redirect_to edit_profile_salary_path, notice: "Salary updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Singular `resource :salary` route — there is no :id, so the record is
  # always the current user's. PATCH intentionally doubles as create via
  # build_salary: the first save persists the row, later saves update it.
  def load_salary
    @salary = Current.user.salary || Current.user.build_salary
  end

  def salary_params
    params.expect(salary: %i[current_amount expected_min expected_max])
  end
end
