#= require_tree ../utils

{ stopEverything } = Rails

input = (name, value) ->
  "<input name='#{name}' " + (if value? then "value='#{value}' " else '') + "type='hidden' />"

inputForParam = (param) ->
  separated = param.split('=')
  input(separated[0], separated[1])

# Handles "data-method" on links such as:
# <a href="/users/5" data-method="delete" rel="nofollow" data-confirm="Are you sure?">Delete</a>
Rails.handleMethod = (e) ->
  link = this
  method = link.getAttribute('data-method')
  return unless method

  href = Rails.href(link)
  csrfToken = Rails.csrfToken()
  csrfParam = Rails.csrfParam()
  data = link.getAttribute('data-params')
  form = document.createElement('form')
  formContent = input('_method', method)

  if csrfParam? and csrfToken? and not Rails.isCrossDomain(href)
    formContent += input(csrfParam, csrfToken)

  if data?
    dataFields = (inputForParam(param) for param in data.split('&'))
    formContent += dataFields.join('')

  # Must trigger submit by click on a button, else "submit" event handler won't work!
  # https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/submit
  formContent += '<input type="submit" />'

  form.method = 'post'
  form.action = href
  form.target = link.target
  form.innerHTML = formContent
  form.style.display = 'none'

  document.body.appendChild(form)
  form.querySelector('[type="submit"]').click()

  stopEverything(e)
