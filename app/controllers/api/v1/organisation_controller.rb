# frozen_string_literal: true

module Api
  module V1
    class OrganisationController < ::ApplicationController
      protect_from_forgery with: :exception

      def search
        result = Organisation.find_organisation(params[:search])
        Rails.logger.debug result.length
        if result.length < 200
          render json: { supplier_names: result, no_results: result.length.zero? }
        else
          render json: { supplier_names: [], no_results: false }
        end
      end
    end
  end
end
