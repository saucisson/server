local Model  = require "lapis.db.model".Model
local result = {}

result.identities = Model:extend ("identities", {
  relations = {
    { "user",
      belongs_to = "users",
      where      = { deleted = false },
    },
  },
})

result.users = Model:extend ("users", {
  timestamp   = true,
  relations   = {
    { "projects",
      has_many = "projects",
      where    = { deleted = false },
    },
    { "identities",
      has_many = "identities",
    },
  },
})

result.stars = Model:extend ("stars", {
  timestamp   = true,
  primary_key = { "user_id", "project_id" },
})

result.projects = Model:extend ("projects", {
  timestamp   = true,
  relations   = {
    { "user",
      belongs_to = "users",
      where      = { deleted = false },
    },
    { "tags",
      has_many = "tags",
    },
    { "stars",
      has_many = "stars",
    },
  },
})

result.tags = Model:extend ("tags", {
  timestamp   = true,
  primary_key = { "id", "project_id" },
  relations   = {
    { "project",
      belongs_to = "projects",
      where      = { deleted = false },
    },
  },
})

result.resources = Model:extend ("resources", {
  timestamp   = true,
  relations   = {
    { "project",
      belongs_to = "projects",
      where      = { deleted = false },
    },
  },
})

result.resources = Model:extend ("executions", {
  timestamp   = true,
  relations   = {
    { "resource",
      belongs_to = "resources",
      where      = { deleted = false },
    },
  },
})

return result
