# RiotApi

Thin wrapper for RiotApi.

  Config it:

  ``` elixir
  config :riot_api,
    key: "your-api-key",
    wait: 1000, #ms's to wait between non-static calls
    default_platform: "na1"
  ```
  You can use named params:
  ``` bash
  iex> RiotApi.req(service: "static-data", resource: "champions")
  ```
  Available params are platform, service, resource, query(query string), version and game.
  You're probably only gonna need the first 4.
  There's some higher levels methods you can find in the code.


## Installation

I may create a hex package in the future when this gets better polish, but for now you can install like this:

```elixir
def deps do
  [{:riot_api, git: "https://github.com/erikdsi/riot_api"}]
end
```
