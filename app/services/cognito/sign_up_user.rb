# frozen_string_literal: true

module Cognito
  class SignUpUser < BaseService
    include ActiveModel::Validations
    validates_presence_of :email, :first_name, :last_name, :summary_line
    validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP, message: I18n.t('activemodel.errors.models.ccs_patterns/home/cog_register.attributes.email_format')

    validates :first_name,
              length: { minimum: 2 }
    validates :last_name,
              length: { minimum: 2 }

    include PasswordValidator

    validate :domain_in_allow_list, unless: -> { errors[:email].any? }
    validate :organisation_present
    attr_reader :email, :first_name, :last_name, :summary_line, :password, :password_confirmation, :organisation
    attr_accessor :user, :not_on_allow_list

    def initialize(params = {})
      super()
      @email = params[:email].try(:downcase)
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
      @summary_line = params[:summary_line]
      @organisation = Organisation.find_organisation(@summary_line)
      @first_name = params[:first_name]
      @last_name = params[:last_name]
      @not_on_allow_list = nil
    end

    def call
      if valid?
        resp = create_cognito_user
        @cognito_uuid = resp['user_sub']
      end
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      errors.add(:base, e.message)
    end

    def success?
      errors.none?
    end

    private

    def create_cognito_user
      client.sign_up(
        client_id: ENV['COGNITO_CLIENT_ID'],
        secret_hash: Cognito::Common.build_secret_hash(email),
        username: email,
        password: password,
        user_attributes: [
          {
            name: 'email',
            value: email
          },
          {
            name: 'name',
            value: first_name
          },
          {
            name: 'family_name',
            value: last_name
          },
          {
            name: 'custom:organisation_name',
            value: organisation.organisation_name
          },
          # Some user do not have phone number so we add adummy number
          # just so cognito can have a number cognito limitaions.
          {
            name: 'phone_number',
            value: '+4408654876588'
          }
        ]
      )
    end

    # rubocop:disable Style/GuardClause
    def domain_in_allow_list
      unless AllowedEmailDomain.exists?(url: domain_name)
        errors.add(:email, :not_on_allow_list)
        @not_on_allow_list = true
      end
    end
    # rubocop:enable Style/GuardClause

    def domain_name
      email.squish!.split('@').last
    end

    def organisation_present
      return if errors.include?(:summary_line) || organisation.present?

      errors.add(:summary_line, :not_found)
      @summary_line = nil
    end
  end
end
