--[[
local crud = require "kong.api.crud_helpers"
local singletons = require "kong.singletons"
local dao_factory = singletons.dao

local keys_dao = dao_factory.oauth2_audit

return {
    ["/audits"] = {
        GET = function(self, dao_factory, helpers)
            local key_credential, err = dao_factory.audits:find_all({
                principal = res.preferred_username,
                event_type = "AUTHENTICATION_SUCCESS" --AUTHENTICATION_SUCCESS
            })
        end
    }
}


]]

--[[
local endpoints = require "kong.api.endpoints"
local audits_schema = kong.db.audits.schema

return {
    ["/audits"] = {
        --GET = endpoints.get_entity_endpoint(audits_schema)
        GET = kong.response.exit(200, kong.db.audits:select({principal = "admin"}))
    }
}]]

local endpoints   = require "kong.api.endpoints"


return {
    ["/audits"] = {
        GET = function(self, db, helpers, parent)
            return kong.response.exit(200, {
                data   = db.audits:select({principal = "admin"})
            })
        end
    }
}