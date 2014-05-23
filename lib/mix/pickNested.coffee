nestedPick = (argv...) ->
  [object, keys] = argv

  # Delegate to the original function if not applicable
  # return _._pick.apply @, argv if not _.isObject keys, true

  # Pick out elements marked as pick
  copy  = {}
  for key in keys
    props = key.split('.')
    # $log 'props', props
    if props.length is 1
      # $log 'picking.key', key
      # Pick the marked element
      copy[key] = object[key] if object[key]?
    else
      # Pick recursively and apply only if something was picked
      # $log 'picking.recursive.key', key, props[0]
      result = nestedPick object[props[0]], [key.replace("#{props[0]}.",'')]
      copy[props[0]] = result unless _.isEmpty result

  return copy


module.exports = nestedPick
