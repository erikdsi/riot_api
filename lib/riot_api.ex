defmodule RiotApi do
  alias HTTPoison
  alias Poison
  require Logger

  @api_key Application.get_env(:riot_api, :key)
  @default_platform Application.get_env(:riot_api, :default_platform) || "na1"
  @wait Application.get_env(:riot_api, :wait) || 0


  @game "lol"
  @version "v3"

  @moduledoc """
  Simple wrapper for RiotApi.

  Config it:
  ``` elixir
  config :riot_api,
    key: "your-api-key",
    wait: 1000, #ms's to wait between non-static calls
    default_platform: "na1"
  ```
  You can use named params
  ``` bash
  iex> RiotApi.req(service: "static-data", resource: "champions")
  ```

  Available params are platform, service, resource, query(query string), version and game.
  You're probably only gonna need the first 4, and there's some higher levels methods you can find in the code.

  """


  def parse_response(response, url) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- response,
         {:ok, parsed} <- Poison.decode(body) do
      {:ok, parsed}
    else
      {:ok, %HTTPoison.Response{status_code: status, body: body}} -> {:error, %{"status" => status, "body" => body}}
      {_, error} -> Logger.debug(inspect([url: url, payload: error]))
    end
  end

  def req(options \\ []) do
    defaults = [platform: @default_platform, service: "", resource: "", query: "", version: @version, game: @game]
    opts = Keyword.merge(defaults, options)
    request(opts[:platform], opts[:service], opts[:resource], opts[:query], opts[:version], opts[:game])
  end
  def req(service, resource, query \\ "", version \\ @version, game \\ @game) do
    request(@default_platform, service, resource, query, version, game)
  end

  def request(platform, service, resource, query \\ "", version \\ @version, game \\ @game) when is_binary(query) do
    if service != "static-data" do
      :timer.sleep(@wait)
    end
    query = if String.starts_with?(query, "?") || query == "" do query else "?" <> query end
    url = "https://#{platform}.api.riotgames.com/#{game}/#{service}/#{version}/#{resource}" <> URI.encode(query)
    headers = ["Accept-Charset": "application/x-www-form-urlencoded; charset=UTF-8", "X-Riot-Token": @api_key]
    parse_response(HTTPoison.get(url, headers), url)
  end

  def static(resource, query \\ "") do
    req("static-data", resource, query)
  end

  def challenger(region \\ @default_platform, queue \\ "RANKED_SOLO_5x5") do
    req(platform: region, service: "league", resource: "challengerleagues/by-queue/#{queue}")
  end

  def matchlist(account_id, query \\ "", region \\ @default_platform) do
    req(platform: region, service: "match", resource: "matchlists/by-account/#{account_id}", query: query)
  end
  def recent_matchlist(account_id, region \\ @default_platform) do
    req(platform: region, service: "match", resource: "matchlists/by-account/#{account_id}/recent")
  end

  def match(match_id, region \\ @default_platform) do
    req(platform: region, service: "match", resource: "matches/#{match_id}")
  end

  def timeline(match_id, region \\ @default_platform) do
    req(platform: region, service: "match", resource: "timelines/by-match/#{match_id}")
  end

  def summoner(summoner_id, region \\ @default_platform) do
    req(platform: region, service: "summoner", resource: "summoners/#{summoner_id}")
  end


end
