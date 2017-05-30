defmodule RiotApiTest do
  use ExUnit.Case, async: true

  test "static request" do
    {:ok, champions} = RiotApi.static("champions", "dataById=true")
    clist = Map.to_list(champions["data"])
    {_, galio} = Enum.find(clist, fn(el)->
      elem(el, 0) == "3"
    end)
    assert galio["name"] == "Galio"
  end
end
