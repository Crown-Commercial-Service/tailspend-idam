import accessibleAutocomplete from 'accessible-autocomplete';

let noResults = false;

const pmpAutoComplete = {
  autocomplete_int: [],

  query(query, populateResults) {
    if (query.length > 2) {
      $.ajax({
        url: '/api/v1/organisation-search',
        type: 'get',
        data: {
          search: query,
        },
        success(response) {
          populateResults(response.organisation_names);
          noResults = response.noResults;
        },
        error() {},
      });
    }
  },

  init_auto_complete() {
    pmpAutoComplete.autocomplete_int = accessibleAutocomplete({
      element: document.querySelector('#my-autocomplete-container'),
      id: 'organisation-input',
      source: pmpAutoComplete.query,
      name: 'anything[organisation-input]',
      minLength: 3,
      defaultValue: $('#cognito_sign_up_user_organisation').val(),
      showNoOptionsFound: true,
      tNoResults() {
        if (noResults) {
          return 'No results found';
        }
        return 'Search for a more specific term';
      },
      onConfirm(query) {
        if (query !== undefined) {
          $('#cognito_sign_up_user_organisation').val(query);
          $('#selected-autocomplete-option').show();
          $('#selected-autocomplete-option p span').text(query);
        }
      },
    });

    $('#organisation-input').on('keyup', (e) => {
      if ($(e.target).val() !== $('#selected-autocomplete-option p span').text()) {
        $('#cognito_sign_up_user_organisation').val('');
        $('#selected-autocomplete-option').hide();
        $('#selected-autocomplete-option p span').text('');
      }
    });
  },
};

$(() => {
  if ($('#my-autocomplete-container').length > 0) {
    pmpAutoComplete.init_auto_complete();
  }
});
