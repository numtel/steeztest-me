# steeztest.me
# MIT License ben@latenightsketches.com
# Extract computed styles and applied rules of all elements in html code

# 3 Required Options:
# html   - string containing the page's html source
# url    - string matches the same origin as the stylesheets in order to read
#          the applied rules (security policy)
# widths - array of integers specify which viewport widths to test (in pixels)

@phantomMethods = @phantomMethods || {}

phantomMethods.extractStyles = (options, callback) ->
  page = require('webpage').create()

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
      collected = {}
      options.widths.forEach (testWidth)->
        page.viewportSize =
          width: testWidth
          height: 800
        output = page.evaluate ->
          elementStyleAttributes = (el, style) ->
            if style == undefined
              style = window.getComputedStyle el
            attributes = {}
            for j in [0...style.length]
              propertyName = style.item j
              attributes[propertyName] = style.getPropertyValue propertyName
            return attributes
          extractChildStyles = (base, baseSelector) ->
            if baseSelector == undefined
              baseSelector = ''
            childOutput = []
            for child, i in base.children
              classes = ''
              for childClass in child.classList
                classes += '.' + childClass
              selector = baseSelector + '>' + child.nodeName + \
                         (if child.id then '#' + child.id else '') + classes + \
                         ':nth-child(' + (i+1) + ')'

              # getMatchedCSSRules only works for stylesheets from the same origin
              ruleList = child.ownerDocument.defaultView.getMatchedCSSRules child, ''
              rules = []
              if ruleList
                for rule in ruleList.length
                  rules.push
                    selector: rule.selectorText
                    sheet: rule.parentStyleSheet.href
                    attributes: elementStyleAttributes(undefined, rule.style)

              childOutput.push
                ignore: child.attributes.hasOwnProperty 'test-ignore'
                selector: selector
                attributes: elementStyleAttributes child
                rules: rules
                children: extractChildStyles child, selector
            return childOutput
          # Recurse through <body> children
          elementStyles = extractChildStyles document.body, 'BODY'
          # <html> and <body> separately
          [['HTML', document.documentElement], ['BODY', document.body]] \
          .forEach (additional) ->
            elementStyles.push
              ignore: additional[1].attributes.hasOwnProperty 'test-ignore'
              selector: additional[0]
              attributes: elementStyleAttributes additional[1]
              children: []
          return elementStyles
        collected[testWidth] = output
      callback undefined, collected
      return
    else
      callback
        code: 'invalid-html'
      return

  page.setContent options.html, options.url
