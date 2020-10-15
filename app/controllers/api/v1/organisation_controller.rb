# frozen_string_literal: true

module Api
  module V1
    class OrganisationController < ::ApplicationController
      protect_from_forgery with: :exception

      def search
        result = Organisation.where(['supllier_name LIKE ?', "%#{params[:search]}%"]).pluck(:supllier_name)
        render json: result
      end
    end
  end
end
