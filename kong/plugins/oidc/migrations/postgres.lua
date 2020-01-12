return {
    postgres = {
        up = [[
      CREATE TABLE IF NOT EXISTS "audits" (
        "id"           UUID                         PRIMARY KEY,
        "created_at"   TIMESTAMP WITHOUT TIME ZONE  DEFAULT (CURRENT_TIMESTAMP(0) AT TIME ZONE 'UTC'),
        "principal"  TEXT,
        "event"          TEXT
      );
    ]],
    },

    cassandra = {
        up = [[
      CREATE TABLE IF NOT EXISTS audits(
        id          uuid PRIMARY KEY,
        created_at  timestamp,
        principal text,
        event         text
      );
      CREATE INDEX IF NOT EXISTS ON keyauth_credentials_test(principal);
    ]],
    }
}