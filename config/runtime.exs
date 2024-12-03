import Config

config :kv, :routing_table, [{?a..?z, node()}]

if config_env() == :prod do
  config :kv, :routing_table, [
    {?a..?m, :"foo@MacBook-Pro-de-MacBook"},
    {?n..?z, :"bar@MacBook-Pro-de-MacBook"}
  ]
end
