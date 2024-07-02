import initAutoComplete from './modules/autocomplete'
import initCookieBanner from './modules/cookieBanner'
import initGoogleAnalyticsDataLayer from './modules/googleAnalyticsDataLayer'

const initAll = () => {
  initAutoComplete()
  initCookieBanner()
  initGoogleAnalyticsDataLayer()
}

export { initAll }
