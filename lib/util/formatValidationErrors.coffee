#
# Turns expressValidator errors into the object format that BadassBackbone
# understands.
#
reducer = (hash, error) ->
  hash[error.param] = error.msg
  hash

module.exports = (validationErrors) ->
  data:
    validationErrors.reduce reducer, {}
