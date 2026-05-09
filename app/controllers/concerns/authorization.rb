# typed: false

module Authorization
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :forbidden

    private

    def pundit_user
      Current.user
    end

    def forbidden
      render plain: "Forbidden", status: :forbidden
    end
  end
end
