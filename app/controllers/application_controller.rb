# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def get_error_list(errors_object)
    errors_object.details.transform_values { |errors| errors.pluck(:error) }
  rescue StandardError
    errors_object.details
  end
end
