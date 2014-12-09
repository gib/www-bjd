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

  contact: ->
    @setStyle 'contact'

  clients: ->
    @setStyle 'clients'

  sections: (section, subsection, page) ->
    Site.$body.removeClass(Site.sectionClasses).addClass(section)
    Site.$body.addClass 'loading'
    $('.active').removeClass 'active'
    $("a[href^='/#{section}/#{subsection}']:not(.page), a.page[href='#{location.pathname}']").addClass 'active'
    $("a.page[href='#{location.pathname}']").closest('.subnav-parent').find('a').first().addClass 'active'
    Site.$image.one 'load', -> Site.$body.removeClass 'loading'
    _.delay (=> _.once(=>
      Site.$body.removeClass 'loading'
      Site.$image.attr 'src', "/images#{location.pathname}.jpg"
    )), 4000
    Site.$image.attr 'src', "/images#{location.pathname}.jpg"

  setStyle: (section) ->
    $('.active').removeClass 'active'
    Site.$body.removeClass(Site.sectionClasses, 'loading').addClass section

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
  # Run the current route's callback
  Site.router.navigate location.pathname, trigger: true

  # Store pageUrls for preloading images and moving through the pages via keyboard
  $('nav .subnav a').each ->
    href = $(@).attr 'href'
    unless Site.pageUrls.indexOf(href) > -1
      Site.pageUrls.push(href)
  # clone page urls with images before adding clients and contacts
  imgPages = Site.pageUrls.slice(1) # ignore '/'
  Site.pageUrls.push '/clients'
  Site.pageUrls.push '/contact'

  # Prefetch all the portfolio images
  $img = $ '<img>'
  loadImage = (url) ->
    console.log "Called loadImage", url, (new Date)
    return if imgPages.length is 0
    src = "/images#{url}.jpg"
    $img.one 'load', ->
      _.delay (-> loadImage imgPages.shift()), 1000
    $img.src = src
    if $img.get(0).complete # Cached?
      $img.off 'load'
      _.delay (-> loadImage imgPages.pop()), 1000
  # KICK IT!
  _.defer -> loadImage imgPages.shift()
