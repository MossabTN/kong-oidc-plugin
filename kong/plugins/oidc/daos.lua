local typedefs = require "kong.db.schema.typedefs"

return {
    audits = {
        primary_key = { "id" },
        name = "audits",
        endpoint_key = "principal",
        --cache_key = { "principal" },
        admin_api_name = "audits",
        admin_api_nested_name = "audit",
        fields = {
            { id = typedefs.uuid },
            { created_at = typedefs.auto_timestamp_s },
            { principal = { type = "string", required = true }, },
            { event = { type = "string", required = true}, },
        },
    },
}