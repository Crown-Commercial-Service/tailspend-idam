const getInputElement = (errorID) => $(errorID).parent('.govuk-form-group').find('input[type="text"],input[type="email"],input[type="password"]');

const addFocusEvent = (error) => {
  $(error).on('click', (e) => {
    getInputElement(error.hash).trigger('focus');

    e.preventDefault();
  });
};

const initErrorLinks = () => {
  const errorSummary = $('.govuk-error-summary__list');

  if (errorSummary.length) {
    const errorLinks = $('.govuk-error-summary__list > li > a');

    errorLinks.each((_, element) => addFocusEvent(element));
  }
}

export { initErrorLinks }
