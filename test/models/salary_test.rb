# typed: false

require "test_helper"

class SalaryTest < ActiveSupport::TestCase
  test "all amount fields are optional" do
    salary = Salary.new(user: create(:user, :member))
    assert salary.valid?
  end

  test "rejects negative amounts" do
    salary = build(:salary, current_amount: -1)
    assert_not salary.valid?
    assert_includes salary.errors[:current_amount], "must be greater than or equal to 0"
  end

  test "rejects expected_max lower than expected_min" do
    salary = build(:salary, expected_min: 200, expected_max: 100)
    assert_not salary.valid?
    assert_includes salary.errors[:expected_max], "must be greater than or equal to expected min"
  end

  test "accepts equal expected_min and expected_max" do
    salary = build(:salary, expected_min: 150, expected_max: 150)
    assert salary.valid?
  end

  test "saving a salary with values bumps the owner profile_updated_at" do
    user    = create(:user, :member)
    profile = user.create_profile!(name: "Ada")
    assert_nil profile.profile_updated_at

    user.create_salary!(current_amount: 100_000)

    assert_not_nil profile.reload.profile_updated_at
  end

  test "destroying a salary bumps the owner profile_updated_at" do
    user    = create(:user, :member)
    profile = user.create_profile!(name: "Ada")
    salary  = user.create_salary!(current_amount: 100_000)
    initial = profile.reload.profile_updated_at

    travel 1.minute do
      salary.destroy
    end

    assert profile.reload.profile_updated_at > initial
  end

  test "saving a salary with all blank fields does not bump profile_updated_at" do
    user    = create(:user, :member)
    profile = user.create_profile!(name: "Ada")

    user.create_salary!

    assert_nil profile.reload.profile_updated_at
  end
end
