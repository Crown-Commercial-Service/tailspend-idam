# frozen_string_literal: true

module Api
  module V1
    class OrganisationController < ::ApplicationController
      protect_from_forgery with: :exception

      def search
        result = Organisation.search_organisations(params[:search])
        Rails.logger.debug result.length
        if result.length < 200
          render json: { summary_lines: result, no_results: result.length.zero? }
        else
          render json: { summary_lines: [], no_results: false }
        end
      end
    end
  end
end
