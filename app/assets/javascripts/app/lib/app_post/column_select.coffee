class App.ColumnSelect extends Spine.Controller
  elements:
    '.js-pool': 'pool'
    '.js-selected': 'selected'
    '.js-shadow': 'shadow'
    '.js-placeholder': 'placeholder'
    '.js-pool .js-option': 'poolOptions'
    '.js-selected .js-option': 'selectedOptions'
    '.js-search': 'search'
    '.js-clear': 'clearButton'

  events:
    'click .js-select': 'onSelect'
    'click .js-remove': 'onRemove'
    'input .js-search': 'filter'
    'click .js-clear': 'clear'
    'keydown .js-search': 'onFilterKeydown'

  className: 'form-control columnSelect'

  element: =>
    @el

  constructor: ->
    super
    @values = []
    @render()

  render: ->
    @html App.view('generic/column_select')( @options.attribute )

    # keep inital height
    # disabled for now since controls in modals get rendered hidden
    # and thus have no height
    # setTimeout =>
    #   @el.css 'height', @el.height()
    # , 0

  onSelect: (event) ->
    @select $(event.currentTarget).attr('data-value')

  select: (value) ->
    @selected.find("[data-value='#{value}']").removeClass 'is-hidden'
    @pool.find("[data-value='#{value}']").addClass 'is-hidden'
    @values.push(value)
    @shadow.val(@values)

    @placeholder.addClass 'is-hidden'

    if @search.val() and @poolOptions.not('.is-filtered').not('.is-hidden').size() is 0
      @clear()

  onRemove: (event) ->
    @remove $(event.currentTarget).attr('data-value')

  remove: (value) ->
    @pool.find("[data-value='#{value}']").removeClass 'is-hidden'
    @selected.find("[data-value='#{value}']").addClass 'is-hidden'
    @values.splice(@values.indexOf(value), 1)
    @shadow.val(@values)

    if !@values.length
      @placeholder.removeClass 'is-hidden'

  filter: (event) ->
    filter = $(event.currentTarget).val()

    @poolOptions.each (i, el) ->
      return if $(el).hasClass('is-hidden')

      if $(el).text().indexOf(filter) > -1
        $(el).removeClass 'is-filtered'
      else
        $(el).addClass 'is-filtered'

    @clearButton.toggleClass 'is-hidden', filter.length is 0

  clear: ->
    @search.val('')
    @poolOptions.removeClass 'is-filtered'
    @clearButton.addClass 'is-hidden'

  onFilterKeydown: (event) ->
    return if event.keyCode != 13
    
    firstVisibleOption = @poolOptions.not('.is-filtered').not('.is-hidden').first()
    if firstVisibleOption
      @select firstVisibleOption.attr('data-value')