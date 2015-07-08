#
# Betsy Joyce Design
#
# Author: gib
#
# Globals
#
window.Site = {}
window.Site.sections = [ 'advertisements', 'art-catalogs', 'clients', 'contact',
                         'booklets', 'brochures', 'home', 'identity',
                         'invitations', 'newsletters', 'annual-reports' ]
window.Site.sectionClasses = window.Site.sections.join ' '

#
# Router
#
class SiteRouter extends Backbone.Router

  routes:
    ''                               : 'home'
    'contact'                        : 'contact'
    'clients'                        : 'clients'
    ':section(/:subsection)(/:page)' : 'sections'

  home: ->
    @setStyle 'home'
    @updateGoogleAnalytics()

  contact: ->
    @setStyle 'contact'
    @updateGoogleAnalytics()

  clients: ->
    @setStyle 'clients'
    @updateGoogleAnalytics()

  sections: (section, subsection, page) ->
    Site.$body.removeClass(Site.sectionClasses).addClass(section)
    $('.active').removeClass 'active'
    $("a[href^='/#{section}/#{subsection}/']:not(.page), a.page[href='#{location.pathname}']").addClass 'active'
    $("a.page[href='#{location.pathname}']").closest('.subnav-parent').find('a').first().addClass 'active'
    Site.$image.attr 'src', "/images#{location.pathname}.jpg"
    @updateGoogleAnalytics()

  setStyle: (section) ->
    $('.active').removeClass 'active'
    Site.$body.removeClass(Site.sectionClasses, 'loading').addClass section

  updateGoogleAnalytics: ->
    ga 'set', 'page', location.pathname
    ga 'send', 'pageview'

  # Capture internal links
  linkHandler: (event) =>
    path = $(event.currentTarget).attr('href')
    # Allow shift+click for new tabs, etc.
    if !event.altKey && !event.ctrlKey && !event.metaKey && !event.shiftKey
      event.preventDefault()
    @navigate path, trigger: true
    false

  # Capture keypress
  keyupHandler: (event) =>
    page = Site.pageUrls.indexOf(location.pathname)
    prev = page - 1
    next = page + 1
    # Wrap around if out of the array
    if prev < 0
      prev = Site.pageUrls.length - 1
    if next >= Site.pageUrls.length
      next = 0
    # Forward or back?
    if _.contains([37, 72], event.keyCode)
      newPath = Site.pageUrls[prev]
    if _.contains([39, 76], event.keyCode)
      newPath = Site.pageUrls[next]
    # Route it
    Site.router.navigate newPath, trigger: true if newPath?

#
# Init
#
$ ->
  # Global references
  Site.$doc          = $ document
  Site.$body         = $ 'body'
  Site.$imageContent = $ '.image-content'
  Site.$image        = $ '.image-content img'
  Site.router        = new SiteRouter()
  Site.pageUrls      = ['/']

  # Document level events: internal links and keyups
  Site.$doc
    .on('click', "a[href^='/']", Site.router.linkHandler)
    .on('keyup', Site.router.keyupHandler)

  # Kick of backbone to route this as a single page app
  Backbone.history.start pushState: true

  # Run the current route's callback and check for trailing slash
  path = location.pathname
  path = path.substr(0, path.length - 1) if path.substr(-1) is '/'
  Site.router.navigate path, trigger: true

  # Store pageUrls for preloading images and moving through the pages via keyboard
  $('nav .subnav a').each ->
    href = $(@).attr 'href'
    unless Site.pageUrls.indexOf(href) > -1
      Site.pageUrls.push(href)
  # clone page urls with images before adding clients and contacts
  imgPages = Site.pageUrls.slice(1) # ignore '/'
  Site.pageUrls.push '/clients'
  Site.pageUrls.push '/contact'
