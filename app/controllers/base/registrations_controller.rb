# frozen_string_literal: true

module Base
  class RegistrationsController < ApplicationController
    protect_from_forgery
    before_action :authenticate_user!, except: %i[new create domain_not_on_whitelist]
    before_action :authorize_user, except: %i[new create domain_not_on_whitelist]

    def new
      @result = Cognito::SignUpUser.new(nil, nil, nil, nil, nil, nil)
      @result.errors.add(:base, flash[:error]) if flash[:error]
      @result.errors.add(:base, flash[:alert]) if flash[:alert]
    end

    # rubocop:disable Metrics/AbcSize
    def create
      @result = Cognito::SignUpUser.call(params[:anything][:email], params[:anything][:password], params[:anything][:password_confirmation], params[:anything][:organisation], params[:anything][:first_name], params[:anything][:last_name])
      if @result.success?
        # set_flash_message! :notice, :signed_up
        # respond_with resource, location: after_sign_up_path_for(resource)
        redirect_to base_users_confirm_path(email: params[:anything][:email])

      else
        fail_create(@result)
      end
    end
    # rubocop:enable Metrics/AbcSize

    def domain_not_on_whitelist; end

    private

    def fail_create(result)
      if result.not_on_whitelist
        redirect_to base_domain_not_on_whitelist_path
      else
        render :new, erorr: result.error
      end
    end
  end
end
