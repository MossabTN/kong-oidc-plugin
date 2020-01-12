return {
    {
        name = "init_oauth_audit",
        up =  [[
      CREATE TABLE IF NOT EXISTS oauth_audit(
        id uuid,
        principal text,
        event_type text,
        created_at timestamp,
        PRIMARY KEY (id)
      );

    ]],
        down = [[
      DROP TABLE oauth_audit;
    ]]
    }
}