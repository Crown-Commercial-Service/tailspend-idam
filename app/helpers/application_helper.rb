# frozen_string_literal: true

module ApplicationHelper
  def error_id(attribute)
    "#{attribute}-error"
  end

  def display_error(model, attribute)
    error = model.errors[attribute].first
    return if error.blank?

    tag.span(id: error_id(attribute), class: 'govuk-error-message govuk-!-margin-top-3') do
      error.to_s
    end
  end

  def page_title
    title = %i[page_title].map do |title_bit|
      content_for(title_bit)
    end
    title += [t('layouts.application.title')]
    title.compact_blank.map(&:strip).join(': ')
  end

  def form_group_with_error(model, attribute)
    css_classes = ['govuk-form-group']
    any_errors = model.errors.include? attribute
    css_classes += ['govuk-form-group--error'] if any_errors

    tag.div(class: css_classes, id: "#{attribute}-form-group") do
      yield(display_error(model, attribute), any_errors)
    end
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
