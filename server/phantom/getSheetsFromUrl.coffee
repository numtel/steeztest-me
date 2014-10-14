# steeztest.me
# MIT License ben@latenightsketches.com
# Extract computed styles and applied rules of all elements in html code

# Extract all <link rel="stylesheet"> and <style> tags from a page by URL
# 1 Required Option:
# url - string url to extract

@phantomMethods = @phantomMethods || {}

phantomMethods.getSheetsFromUrl = (options, callback) ->
  page = require('webpage').create()

  page.open options.url, (status) ->
    if status == 'success'
      extractedSheets = page.evaluate ->
        output = ''
        styleTags = document.getElementsByTagName 'style'
        output += styleTag.outerHTML + '\n' for styleTag in styleTags
        linkTags = document.getElementsByTagName 'link'
        output += '<link rel="stylesheet" media="' + linkTag.media + '" ' + \
                  'href="' + linkTag.href + '" type="' + linkTag.type + '">\n' \
                  for linkTag in linkTags \
                  when linkTag.rel.toLowerCase() is 'stylesheet'
        return output
      callback undefined, extractedSheets
    else
      callback
        code: 'load-failure'
