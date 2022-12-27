defmodule Awex.AwesomeListTest do
  use Awex.DataCase, async: true

  alias Awex.AwesomeList
  alias Awex.ParserFixtures

  setup_all do
    %{sections: ParserFixtures.value()}
  end

  describe "storing awesome sections with list in DB" do
    test "parsed sections successfully stored in DB", %{sections: parsed_sections} do
      AwesomeList.add_sections(parsed_sections)

      stored_sections = AwesomeList.list_sections()

      assert length(parsed_sections) == length(stored_sections)
      assert Map.get(hd(parsed_sections), :title) == Map.get(hd(stored_sections), :title)

      assert Map.get(List.last(parsed_sections), :title) ==
               Map.get(List.last(stored_sections), :title)
    end
  end
end
