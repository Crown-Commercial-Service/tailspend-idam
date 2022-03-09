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
    title.reject(&:blank?).map(&:strip).join(': ')
  end

  def form_group_with_error(model, attribute)
    css_classes = ['govuk-form-group']
    any_errors = model.errors.include? attribute
    css_classes += ['govuk-form-group--error'] if any_errors

    tag.div(class: css_classes, id: "#{attribute}-form-group") do
      yield(display_error(model, attribute), any_errors)
    end
  end

  def aria_invalid(model, attribute)
    model.errors.include? attribute
  end

  def parameters_without_user_details
    request.parameters.except(:cognito_sign_in_user)
  end

  def header_link_text
    controller.controller_name == 'sessions' && controller.action_name == 'new' ? t('layouts.application.go_back') : t('layouts.application.sign_in')
  end
end
