# frozen_string_literal: true

module Api
  module V1
    class OrganisationController < ::ApplicationController
      protect_from_forgery with: :exception

      def search
        result = Organisation.where(['lower(supllier_name) LIKE ?', "%#{params[:search].downcase}%"]).pluck(:supllier_name)
        Rails.logger.debug result.length
        if result.length < 100
          render json: result
        else
          render json: []
        end
      end
    end
  end
end
