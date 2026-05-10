# typed: false

require "application_system_test_case"

class ProfileEditingTest < ApplicationSystemTestCase
  setup do
    @member = create(:user, :member)
    sign_in_as(@member)
  end

  test "a member fills every section and sees it back on a return visit" do
    visit edit_profile_path

    within :element, "section", text: "Basic info" do
      fill_in "Name", with: "Ada Lovelace"
      fill_in "Headline", with: "Engineer"
      fill_in "Bio", with: "Hello world."
      click_button "Save basic info"
    end
    assert_text "Profile updated."

    within :element, "section", text: "Work history" do
      fill_in "Company", with: "Acme"
      fill_in "Title", with: "Engineer"
      fill_in "Start date", with: "2020-01-01"
      click_button "Add work history"
    end
    assert_text "Work history added."

    within :element, "section", text: "Education" do
      fill_in "School", with: "MIT"
      fill_in "Degree", with: "BSc"
      fill_in "Field", with: "Computer Science"
      fill_in "Start date", with: "2014-09-01"
      click_button "Add education"
    end
    assert_text "Education added."

    within :element, "section", text: "Skills" do
      fill_in "Add a skill", with: "Ruby"
      click_button "Add"
    end

    visit edit_profile_path

    assert_field "Name", with: "Ada Lovelace"
    assert_field "Headline", with: "Engineer"
    assert_field "Bio", with: "Hello world."
    within("#work-histories") { assert_field "Company", with: "Acme" }
    within("#educations")     { assert_field "School",  with: "MIT" }
    within("#skills")         { assert_text "Ruby" }
    assert_text "Last updated"
  end

  test "a member edits an existing work history entry inline" do
    profile = @member.create_profile!(name: "Ada")
    create(:work_history, profile: profile,
           company: "Acme", title: "Junior Engineer",
           start_date: Date.new(2020, 1, 1))

    visit edit_profile_path

    within "#work-histories" do
      fill_in "Title", with: "Senior Engineer"
      click_button "Save changes"
    end

    assert_text "Work history updated."
    assert_field "Title", with: "Senior Engineer"
  end

  test "a member removes a work history entry via the Turbo confirm dialog" do
    profile = @member.create_profile!(name: "Ada")
    create(:work_history, profile: profile,
           company: "Globex", title: "Lead",
           start_date: Date.new(2018, 1, 1))

    visit edit_profile_path
    within("#work-histories") { assert_field "Company", with: "Globex" }

    accept_confirm do
      within "#work-histories" do
        click_button "Remove"
      end
    end

    assert_text "Work history removed."
    assert_no_selector "#work-histories li"
  end

  test "a member adds a skill then removes it" do
    @member.create_profile!(name: "Ada")
    visit edit_profile_path

    within :element, "section", text: "Skills" do
      fill_in "Add a skill", with: "Ruby"
      click_button "Add"
    end

    within "#skills" do
      assert_text "Ruby"
    end

    accept_confirm do
      within "#skills" do
        click_button "×"
      end
    end

    assert_no_selector "#skills"
  end
end
