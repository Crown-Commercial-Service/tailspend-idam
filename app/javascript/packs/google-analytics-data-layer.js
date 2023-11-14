import Cookies from 'js-cookie'

const grantType = {
  granted: 'granted',
  notGranted: 'not granted'
}

const getCookiePreferences = () => Cookies.get('cookie_preferences') ?? '{}'

const getCookiePreferencesSaved = () => Cookies.get('cookie_preferences_saved') ?? '{}'

const setCookiePreferencesSaved = (cookiePreferences) => {
  Cookies.set('cookie_preferences_saved', JSON.stringify(cookiePreferences), { expires: 365 })
}

const getGrantedText = (state) => state ? grantType.granted : grantType.notGranted

const updateDataLayer = (cookiePreferences) => {
  window.dataLayer.push({
    event: 'gtm_consent_update',
    usage_consent: getGrantedText(cookiePreferences.usage),
    glassbox_consent: getGrantedText(cookiePreferences.glassbox),
    marketing_consent: grantType.notGranted
  })

  setCookiePreferencesSaved(cookiePreferences)
}

const initGoogleAnalyticsDataLayer = () => {
  if (window.dataLayer) {
    const cookiePreferences = getCookiePreferences()
    const cookiePreferencesSaved = getCookiePreferencesSaved()

    if (cookiePreferences !== cookiePreferencesSaved) {
      updateDataLayer(JSON.parse(cookiePreferences))
    }
  }
}

export { initGoogleAnalyticsDataLayer }
