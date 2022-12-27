defmodule Awex.ParserTest do
  use Awex.DataCase
  alias Awex.ParserFixtures

  setup_all do
    [sections: ParserFixtures.value()]
  end

  describe "HTML parser" do
    test "HTML successfully parsed", %{sections: sections} do
      assert length(sections) == 83
    end

    test "first section is Actors", %{sections: sections} do
      actors = hd(sections)
      assert actors.title == "Actors"
      assert length(actors.libs) == 12
    end

    test "last section is YAML", %{sections: sections} do
      yaml = List.last(sections)
      assert yaml.title == "YAML"
      assert length(yaml.libs) == 5
    end
  end
end
