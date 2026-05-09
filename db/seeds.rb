# typed: false

User.find_or_create_by!(email_address: "admin@example.com") do |u|
  u.password = ENV.fetch("SEED_ADMIN_PASSWORD", "admin-password")
  u.role = :admin
end

User.find_or_create_by!(email_address: "member@example.com") do |u|
  u.password = ENV.fetch("SEED_MEMBER_PASSWORD", "member-password")
  u.role = :member
end

User.find_or_create_by!(email_address: "recruiter@example.com") do |u|
  u.password = ENV.fetch("SEED_RECRUITER_PASSWORD", "recruiter-password")
  u.role = :recruiter
end
