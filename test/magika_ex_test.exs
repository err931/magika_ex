defmodule MagikaExTest do
  use ExUnit.Case, async: true

  @fixtures_dir Path.expand("fixtures", __DIR__)

  describe "identify_bytes/1" do
    test "correctly identifies Elixir code in memory" do
      data = """
      defmodule Hello do
        def world, do: "Elixir!"
      end
      """

      assert {:ok, %MagikaEx.Result{} = result} = MagikaEx.identify_bytes(data)
      assert result.label == "elixir"
      assert result.mime_type == "text/plain"
      assert result.group == "code"
      assert result.description == "Elixir script"
      assert result.score >= 0.9
      assert result.is_text == true
    end

    test "handles empty binary" do
      assert {:ok, %MagikaEx.Result{} = result} = MagikaEx.identify_bytes("")
      assert result.label == "empty"
    end
  end

  describe "identify_path/1" do
    test "correctly identifies a JPEG image" do
      path = Path.join(@fixtures_dir, "sample.jpg")

      assert {:ok, %MagikaEx.Result{} = result} = MagikaEx.identify_path(path)
      assert result.label == "jpeg"
      assert result.mime_type == "image/jpeg"
      assert result.group == "image"
      assert result.description == "JPEG image data"
      assert result.score >= 0.9
      assert result.is_text == false
    end

    test "detects a fake ZIP file (executable masquerading as zip)" do
      path = Path.join(@fixtures_dir, "fake.zip")

      assert {:ok, %MagikaEx.Result{} = result} = MagikaEx.identify_path(path)
      assert result.group != "archive"
      assert result.group == "executable"
      assert result.score >= 0.9
      assert result.is_text == false
    end

    test "returns error for non-existent file" do
      assert {:error, :enoent} = MagikaEx.identify_path("non_existent_file")
    end
  end
end
