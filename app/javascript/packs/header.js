class Header {
  constructor() {
    this.$menuButton = $('.ccs-js-header-toggle')
    this.$menu = $(`#${this.$menuButton.attr('aria-controls')}`)

    this.syncState(this.$menu.hasClass('ccs-header__navigation-lists--open'))
    this.setEventListeners()
  }

  syncState = (isVisible) => {
    this.$menuButton.toggleClass('ccs-header__menu-button--open', isVisible)
    this.$menuButton.attr('aria-expanded', String(isVisible))
  }

  setEventListeners = () => {
    this.$menuButton.on('click', () => {
      this.$menu.toggleClass('ccs-header__navigation-lists--open')

      this.syncState(this.$menu.hasClass('ccs-header__navigation-lists--open'))
    })
  }
}

const initHeader = () => {
  if ($('[data-module="ccs-header"]').length) new Header()
}

export { initHeader }
