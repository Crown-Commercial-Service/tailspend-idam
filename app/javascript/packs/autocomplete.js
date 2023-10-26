import accessibleAutocomplete from 'accessible-autocomplete';

let noResults = false;

const tailspendAutoComplete = {
  autocomplete: [],

  query(query, populateResults) {
    if (query.length > 2) {
      $.ajax({
        url: '/api/v1/organisation-search',
        type: 'get',
        data: {
          search: query,
        },
        success(response) {
          populateResults(response.summary_lines);
          noResults = response.noResults;
        },
        error() { },
      });
    }
  },

  initAutoComplete() {
    tailspendAutoComplete.autocomplete = accessibleAutocomplete({
      element: document.querySelector('#my-autocomplete-container'),
      id: 'cognito_sign_up_user_organisation',
      source: tailspendAutoComplete.query,
      name: 'cognito_sign_up_user[organisation_name]',
      minLength: 3,
      defaultValue: $('#cognito_sign_up_user_summary_line').val(),
      showNoOptionsFound: true,
      tNoResults() {
        if (noResults) {
          return 'No results found';
        }
        return 'Search for a more specific term';
      },
      onConfirm(query) {
        if (query !== undefined) {
          $('#cognito_sign_up_user_summary_line').val(query);
        }
      },
    });

    $('#cognito_sign_up_user_organisation').on('keyup', (e) => {
      if ($(e.target).val() !== $('#cognito_sign_up_user_summary_line').val()) {
        $('#cognito_sign_up_user_summary_line').val('');
      }
    });
  },
};

const initAutoComplete = () => {
  if ($('#my-autocomplete-container').length > 0) {
    tailspendAutoComplete.initAutoComplete();
  }
}

export { initAutoComplete }
