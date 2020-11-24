# frozen_string_literal: true

module Cognito
  class SignUpUser < BaseService
    include ActiveModel::Validations
    validates_presence_of :email, :first_name, :last_name, :organisation, :password, :password_confirmation

    validates :password,
              presence: true,
              confirmation: { case_sensitive: true },
              length: { within: 10..200 }
    validates :first_name,
              length: { minimum: 2 }
    validates :last_name,
              length: { minimum: 2 }
    validates_format_of :password, with: /(?=.*[A-Z])/, message: :invalid_no_capitals
    validates_format_of :password, with: /(?=.*\W)/, message: :invalid_no_symbol
    validates_format_of :password, with: /(?=.*[0-9])/, message: :invalid_no_number

    validate :domain_in_whitelist
    attr_reader :email, :first_name, :last_name, :organisation, :password, :password_confirmation
    attr_accessor :user, :not_on_whitelist

    def initialize(email, password, password_confirmation, organisation, first_name, last_name)
      super()
      @email = email
      @password = password
      @password_confirmation = password_confirmation
      @organisation = organisation
      @first_name = first_name
      @last_name = last_name
      @not_on_whitelist = nil
    end

    def call
      if valid?
        resp = create_cognito_user
        @cognito_uuid = resp['user_sub']
        # add_user_to_groups
      end
    rescue Aws::CognitoIdentityProvider::Errors::ServiceError => e
      errors.add(:base, e.message)
    end

    def success?
      errors.empty?
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
            value: organisation
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

    def add_user_to_groups
      client.admin_add_user_to_group(
        user_pool_id: ENV['COGNITO_USER_POOL_ID'],
        username: @cognito_uuid,
        group_name: 'customer'
      )
    end

    # rubocop:disable Style/GuardClause
    def domain_in_whitelist
      unless DomainsWhiteList.exists?(url: domain_name)
        errors.add(:email, :not_on_whitelist)
        @not_on_whitelist = true
      end
    end
    # rubocop:enable Style/GuardClause

    def domain_name
      email.squish!.split('@').last
    end
  end
end
