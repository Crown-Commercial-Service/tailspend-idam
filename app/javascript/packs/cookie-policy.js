import Cookies from 'js-cookie'

const cookieUpdateOptions = [
  {
    cookieName: 'usage',
    cookiePrefixes: ['_ga', '_gi']
  },
  {
    cookieName: 'glassbox',
    cookiePrefixes: ['_cls']
  }
]

const getCookiePreferences = () => {
  const defaultCookieSettings = '{"usage":true,"glassbox":false}'

  return JSON.parse(Cookies.get('cookie_preferences_tailspend') ?? defaultCookieSettings)
}

const removeUnwantedCookies = () => {
  const cookieList = Object.keys(Cookies.get())
  const cookiesToRemove = ['tailspend_cookie_settings_viewed', 'tailspend_google_analytics_enabled', 'tailspend_cookie_options_v1'];
  const cookiePreferences = getCookiePreferences()
  const cookiePrefixes = []

  cookieUpdateOptions.forEach((cookieUpdateOption) => {
    if (!cookiePreferences[cookieUpdateOption.cookieName]) cookiePrefixes.push(...cookieUpdateOption.cookiePrefixes)
  })

  for (let i = 0; i < cookieList.length; i++) {
    const cookieName = cookieList[i]

    if (cookiePrefixes.some((cookiePrefix) => cookieName.startsWith(cookiePrefix))) cookiesToRemove.push(cookieName)
  }

  cookiesToRemove.forEach((cookieName) => { Cookies.remove(cookieName, { path: '/', domain: '.crowncommercial.gov.uk' }) })
}

const removeGACookies = (cookieBannerFormData, successFunction, failureFunction) => {
  let success = false

  $.ajax({
    type: 'GET',
    url: '/cookie-settings/update',
    data: cookieBannerFormData,
    dataType: 'json',
    success() {
      success = true
    },
    error() {
      success = false
    },
    complete() {
      success ? successFunction() : failureFunction()
    }
  }).catch(() => {
    failureFunction()
  })
}

const scrollNotificationBannerIntoView = ($notificationBanner, $otherNotificationBanner) => {
  $otherNotificationBanner.hide()
  $notificationBanner.show()

  const offsetCoordinates = $notificationBanner.offset()

  if (offsetCoordinates !== undefined) {
    $('html, body').animate({ scrollTop: offsetCoordinates.top }, 'slow')
  }
}

const cookiesSaved = () => {
  scrollNotificationBannerIntoView(
    $('#cookie-settings-saved'),
    $('#cookie-settings-not-saved')
  )
}

const cookiesNotSaved = () => {
  scrollNotificationBannerIntoView(
    $('#cookie-settings-not-saved'),
    $('#cookie-settings-saved')
  )
}

const cookieSettingsViewed = ($newBanner) => {
  $('#cookie-options-container').hide()
  $newBanner.show()
}

const cookieSettingsError = () => {
  $('#cookie-settings-not-saved').show()
}

const updateBanner = (isAccepeted, $newBanner) => {
  removeGACookies(
    {
      ga_cookie_usage: isAccepeted,
      glassbox_cookie_usage: isAccepeted
    },
    cookieSettingsViewed.bind(null, $newBanner),
    cookieSettingsError
  )
}

const initCookiePolicy = () => {
  removeUnwantedCookies()

  $('[name="cookies"]').on('click', (event) => {
    event.preventDefault()

    const buttonValue = event.currentTarget.value

    updateBanner(String(buttonValue === 'accept'), $(`#cookies-${buttonValue}ed-container`))
  })

  const $form = $('#update-cookie-setings')

  $form.on('submit', (event) => {
    event.preventDefault()

    $('#cookie-settings-saved').show()

    const formData = Object.fromEntries($form.serializeArray().map((element) => [element.name, element.value]))

    removeGACookies(
      formData,
      cookiesSaved,
      cookiesNotSaved
    )
  })
}

export { initCookiePolicy }
