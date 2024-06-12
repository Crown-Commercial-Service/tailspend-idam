import initAutoComplete from './modules/autocomplete'
import initCookieBanner from './modules/cookieBanner'
import initGoogleAnalyticsDataLayer from './modules/googleAnalyticsDataLayer'
import initPasswordStrength from './modules/passwordStrength'

const initAll = () => {
  initAutoComplete()
  initCookieBanner()
  initGoogleAnalyticsDataLayer()
  initPasswordStrength()
}

export { initAll }
