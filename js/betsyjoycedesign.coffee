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
    Site.$body.removeClass Site.sectionClasses
    $('.active').removeClass 'active'
    $("a[href^='/#{section}/#{subsection}']:not(.page), a.page[href='#{location.pathname}']").addClass 'active'
    Site.$imageContent.css 'background-image', "url(/images#{location.pathname}.jpg)"
    Site.$body.addClass section

  setStyle: (section) ->
    $('.active').removeClass 'active'
    Site.$body.removeClass(Site.sectionClasses).addClass section

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
    $page = $("a.page.active[href='#{location.pathname}']")
    return if $page.siblings().length < 1
    total = $page.siblings().length + 1
    page = $page.data 'page'
    prev = parseInt(page) - 1
    next = parseInt(page) + 1
    newPath = ''
    if _.contains([37, 72], event.keyCode) and prev > 0
      newPath = location.pathname.replace "/#{page}", "/#{prev}"
    if _.contains([39, 76], event.keyCode) and next <= total
      newPath = location.pathname.replace "/#{page}", "/#{next}"
    if newPath isnt ''
      Site.router.navigate newPath, trigger: true

#
# Init
#
$ ->
  Site.$doc          = $ document
  Site.$body         = $ 'body'
  Site.$imageContent = $ '.image-content'
  Site.router = new SiteRouter()

  $(document)
    .on('click', "a[href^='/']", Site.router.linkHandler)
    .on('keyup', Site.router.keyupHandler)

  Backbone.history.start pushState: true
  Site.router.navigate location.pathname, trigger: true
