# frozen_string_literal: true

module ApplicationHelper
  include CCS::FrontendHelpers

  def error_id(attribute)
    "#{attribute}-error"
  end

  def page_title
    title = %i[page_title].map do |title_bit|
      content_for(title_bit)
    end
    title += [t('layouts.application.title')]
    title.compact_blank.map(&:strip).join(': ')
  end

  def parameters_without_user_details
    request.parameters.except(:cognito_sign_in_user)
  end

  def cookie_preferences_settings
    @cookie_preferences_settings ||= begin
      current_cookie_preferences = JSON.parse(cookies[TailspendIdam.cookie_settings_name] || '{}')

      !current_cookie_preferences.is_a?(Hash) || current_cookie_preferences.empty? ? TailspendIdam.default_cookie_options : current_cookie_preferences
    end
  end
end
