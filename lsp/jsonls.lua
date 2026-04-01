return {
  settings = {
    json = {
      -- For more manual selection of schemas visit
      -- https://www.arthurkoziel.com/json-schemas-in-neovim/
      -- schemas = require('schemastore').json.schemas({
      --   select = {
      --     '.eslintrc',
      --     'package.json',
      --   }
      -- }),
      validate = { enable = true },
    }
  },
}
