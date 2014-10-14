# steeztest.me
# MIT License ben@latenightsketches.com
# Return a PNG data URI string thumbnail of html code

# 4 Required Options:
# html      - string containing the page's html source
# testWidth - integer width of viewport in pixels
# width     - integer width of thumbnail image
# height    - integer width of thumbnail image

@phantomMethods = @phantomMethods || {}

phantomMethods.renderThumbnail = (options, callback) ->
  page = require('webpage').create()

  page.zoomFactor = options.width / options.testWidth
  page.viewportSize =
    width: options.width * page.zoomFactor,
    height: options.height * page.zoomFactor

  resourceFailures = []
  page.onResourceReceived = (response) ->
    if response.stage == 'end' && response.status != 200
      resourceFailures.push response.url

  page.onLoadFinished = (status) ->
    if status == 'success'
      if resourceFailures.length
        callback
          code: 'resource-failed'
          data: resourceFailures
        return
      imageData = page.renderBase64 'PNG'
      callback undefined, 'data:image/png;base64,' + imageData
      return
    else
      callback
        code: 'invalid-html'
      return

  page.setContent options.html, 'http://localhost/'
