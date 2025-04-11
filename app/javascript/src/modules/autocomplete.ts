import accessibleAutocomplete from 'accessible-autocomplete'
import { get } from '@rails/request.js'

let noResults = false

const tailspendAutoComplete = {
  autocomplete: [],

  async query(query: string, populateResults: (summaryLines: string[]) => void) {
    if (query.length > 2) {
      try {
        const response = await get(
          '/api/v1/organisation-search',
          {
            query: { search: query }
          }
        )
  
        if (response.ok) {
          const responseData = await response.json
  
          populateResults(responseData.summary_lines)
          noResults = responseData.noResults
        }
      } catch {
        // Do nothing
      }
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
          return 'No results found'
        }
        return 'Search for a more specific term'
      },
      onConfirm(query?: string) {
        if (query !== undefined) {
          $('#cognito_sign_up_user_summary_line').val(query)
        }
      },
    })

    $('#cognito_sign_up_user_organisation').on('keyup', (e) => {
      if ($(e.target).val() !== $('#cognito_sign_up_user_summary_line').val()) {
        $('#cognito_sign_up_user_summary_line').val('')
      }
    })
  },
}

const initAutoComplete = () => {
  if ($('#my-autocomplete-container').length > 0) {
    tailspendAutoComplete.initAutoComplete()
  }
}

export default initAutoComplete
