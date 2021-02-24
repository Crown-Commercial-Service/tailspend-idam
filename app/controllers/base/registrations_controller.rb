# frozen_string_literal: true

module Base
  class RegistrationsController < ApplicationController
    protect_from_forgery
    before_action :authenticate_user!, except: %i[new create domain_not_on_allow_list]
    before_action :authorize_user, except: %i[new create domain_not_on_allow_list]

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
        Rails.logger.info 'SIGN UP SUCCESSFUL'
        redirect_to base_users_confirm_path(email: params[:anything][:email])

      else
        fail_create
      end
    end
    # rubocop:enable Metrics/AbcSize

    def domain_not_on_allow_list; end

    private

    def fail_create
      if @result.not_on_allow_list
        Rails.logger.info 'SIGN UP FAILED: Email domain not on allow list'
        redirect_to base_domain_not_on_allow_list_path
      else
        Rails.logger.info "SIGN UP FAILED: #{get_error_list(@result.errors)}"
        render :new, erorr: @result.error
      end
    end
  end
end
