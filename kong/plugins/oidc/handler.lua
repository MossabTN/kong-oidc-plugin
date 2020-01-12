local BasePlugin = require "kong.plugins.base_plugin"
local OidcHandler = BasePlugin:extend()
local utils = require("kong.plugins.oidc.utils")
local filter = require("kong.plugins.oidc.filter")
local session = require("kong.plugins.oidc.session")
local kong = kong

OidcHandler.PRIORITY = 1000


function OidcHandler:new()
  OidcHandler.super.new(self, "oidc")
end

function OidcHandler:access(config)
  OidcHandler.super.access(self)
  local oidcConfig = utils.get_options(config, ngx)

  if filter.shouldProcessRequest(oidcConfig) then
    session.configure(config)
    handle(oidcConfig)
  else
    ngx.log(ngx.DEBUG, "OidcHandler ignoring request, path: " .. ngx.var.request_uri)
  end

  ngx.log(ngx.DEBUG, "OidcHandler done")
end

function handle(oidcConfig)
  local response
  if oidcConfig.introspection_endpoint then
    response = introspect(oidcConfig)
    if response then
      utils.injectUser(response)
    end
  end

  if response == nil then
    response = make_oidc(oidcConfig)
    if response then
      if (response.user) then
        utils.injectUser(response.user)
      end
      if (response.access_token) then
        utils.injectAccessToken(response.access_token)
      end
      if (response.id_token) then
        utils.injectIDToken(response.id_token)
      end
    end
  end
end

function make_oidc(oidcConfig)
  ngx.log(ngx.DEBUG, "OidcHandler calling authenticate, requested path: " .. ngx.var.request_uri)
  local res, err = require("resty.openidc").authenticate(oidcConfig)
  if err then
    if oidcConfig.recovery_page_path then
      ngx.log(ngx.DEBUG, "Entering recovery page: " .. oidcConfig.recovery_page_path)
      ngx.redirect(oidcConfig.recovery_page_path)
    end
    utils.exit(500, err, ngx.HTTP_INTERNAL_SERVER_ERROR)
  end
  return res
end

function introspect(oidcConfig)
  local param_token = utils.has_param_bearer_access_token();
  if utils.has_bearer_access_token() or oidcConfig.bearer_only == "yes" or param_token ~= nil then
    if utils.has_bearer_access_token() == false and param_token ~= nil then
      ngx.log(ngx.DEBUG, "add Authorization header")
      ngx.req.set_header("Authorization", "Bearer " .. param_token)
      end
    local res, err = require("resty.openidc").introspect(oidcConfig)
    if err then
      if oidcConfig.bearer_only == "yes" then
        ngx.header["WWW-Authenticate"] = 'Bearer realm="' .. oidcConfig.realm .. '",error="' .. err .. '"'
        local key_credential, err2 = kong.db.audits:insert({
          principal = "anonymous",
          event = "AUTHENTICATION_FAILED" --AUTHENTICATION_SUCCESS
        })
        utils.exit(ngx.HTTP_UNAUTHORIZED, err, ngx.HTTP_UNAUTHORIZED)
      end
      return nil
    end
    ngx.log(ngx.DEBUG, "OidcHandler introspect succeeded, requested path: " .. ngx.var.request_uri)
    local key_credential, err2 = kong.db.audits:insert({
      principal = res.preferred_username,
      event = "AUTHENTICATION_SUCCESS" --AUTHENTICATION_SUCCESS
    })
    return res
  end
  return nil
end


return OidcHandler
