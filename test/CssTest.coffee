# Only run these tests on the client  
return if Meteor.isServer

handleError = (error) ->
  if error
    console.log error
    throw error

Tinytest.addAsync 'CssTest - widthsArray', (test, done) ->
  fixtureAccount done, {}, (error, cleanupAccount) ->
    handleError error
    fixtureCssTest cleanupAccount, {}, (error, fixture, cleanup) ->
      handleError error
      test.equal fixture.widthsArray(), [1024, 720]
      cleanup()

Tinytest.addAsync 'CssTest - getHtml', (test, done) ->
  fixtureAccount done, {}, (error, cleanupAccount) ->
    handleError error
    trials = [
      # Test with default mockup
      {
       options: {},
       expected: [
        '<html test-ignore>',
        '<body test-ignore>',
       ]
      },
      # Test alternate fixtureHtml
      {
       options: {fixtureHtml: '<body>something you would not expect</body>'},
       unexpected: [
        '<body test-ignore>'
       ]
      },
      # Test remoteStyles
      {
        fixture: {
          remoteStyles: document.location.origin + \
                        '/mockup/csstest-mockup.html'
          testUrl: document.location.origin
          cssFiles: ''
        },
        options: {},
        expected: [
          'csstest-mockup.css',
          '<base href="' + document.location.origin + '">'
        ]
      },
      # Test remoteStyles error
      {
        fixture: {
          remoteStyles: 'http://invalidurlfosho'
          cssFiles: ''
        },
        options: {},
        expectFailure: 500,
        errorReason: 'Error: failed [500] {"error":500,"reason":{"code":"load-failure"}}'
      }
      {
       options: {
         fixtureHtml: '<html><body>something you would not expect</body></html>'
       },
       expected: [
        'something you would not expect</body>'
       ],
       unexpected: [
        '<html test-ignore>',
        '<body test-ignore>'
       ]
      },
      # Test with normative
      {
       options: {
        normativeValue: [
            {
             selector: 'h1',
             attributes: {'color': '#ff0'},
             children: [
              {
               selector: 'h1>em',
               attributes: {'text-align': 'center'}
              }
             ]
            }
          ]
        },
       expected: [
        'h1{color: #ff0; }',
        'h1>em{text-align: center; }'
       ]
      },
      # Test with normative + diff
      {
       options: {
        normativeValue: [
            {
             selector: 'h1',
             attributes: {'color': '#ff0'},
             children: [
              {
               selector: 'h1>em',
               attributes: {'text-align': 'center'}
              }
             ]
            }
          ],
        diff: [
          # No children in diff, just flat
          {
           selector: 'h1',
           instances: [{key: 'color', bVal: '#000'}]
          }
         ]
       },
       expected: [
        'h1{color: #000; }',
        'h1>em{text-align: center; }'
       ],
      }
    ]

    multipleTestData trials, cleanupAccount, (data, trialDone)->
      fixtureCssTest trialDone, data.fixture, (error, fixture, cleanup) ->
        handleError error
        fixture.getHtml data.options, (error, result)->
          if data.expectFailure
            test.isTrue error?.error == data.expectFailure, 'Expected to fail!'
            test.equal error?.reason, data.errorReason
            return cleanup()
              
          handleError error
          # Result should include fixtureHtml exactly as long as it doesn't
          # have an html tag in it
          fixtureHtml = data.options.fixtureHtml || fixture.fixtureHtml
          if fixtureHtml.indexOf '<html' == -1
            test.isTrue result.indexOf fixtureHtml > -1

          # Result should have basic tags
          ['html', 'head', 'body'].forEach (tag) ->
            matcher = new RegExp '\<' + tag + '[^]+\<\/' + tag + '\>', 'i'
            test.isTrue matcher.test(result), 'Missing tag: ' + tag

          if data.options.normativeValue == undefined
            # CSS Files should be included
            fixture.cssFiles?.split('\n').forEach (href) ->
              href = href.trim()
              if href != ''
                test.isTrue result.indexOf(href) > -1, \
                            'CSS File not included: ' + href
          else
            # No links only style tags
            test.isFalse /\<link .+rel=\"stylesheet\".+\>/i.test result
            test.isTrue /\<style\>[^]+\<\/style\>/i.test result

          data.expected?.forEach (expected) ->
            test.isTrue result.indexOf(expected) > -1, 'Missing: ' + expected
          data.unexpected?.forEach (unexpected) ->
            test.isTrue result.indexOf(unexpected) == -1, \
                        'Should not have: ' + unexpected
          cleanup()
