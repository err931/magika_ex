defmodule MagikaExTest do
  use ExUnit.Case, async: true

  @fixtures_dir Path.expand("fixtures", __DIR__)

  setup_all do
    start_supervised!(MagikaEx)
    :ok
  end

  describe "identify_bytes/1" do
    test "correctly identifies Elixir code in memory" do
      data = """
      IO.puts Enum.map(1..5, &(&1 * 2)) |> Enum.join(", ")
      """

      result = MagikaEx.identify_bytes(data)

      assert %MagikaEx.Result{} = result
      assert result.label == "elixir"
      assert result.group == "code"
    end

    test "handles empty binary" do
      result = MagikaEx.identify_bytes("")
      assert %MagikaEx.Result{} = result

      assert result.label == "empty"
    end
  end

  describe "identify_path/1" do
    test "correctly identifies a Python file as code" do
      path = Path.join(@fixtures_dir, "sample.py")

      assert {:ok, %MagikaEx.Result{} = result} = MagikaEx.identify_path(path)
      assert result.label == "python"
      assert result.group == "code"
    end

    test "correctly identifies a JPEG image" do
      path = Path.join(@fixtures_dir, "sample.jpg")
      assert {:ok, %MagikaEx.Result{} = result} = MagikaEx.identify_path(path)
      assert result.group == "image"
    end

    test "detects a fake ZIP file (executable masquerading as zip)" do
      path = Path.join(@fixtures_dir, "fake.zip")

      assert {:ok, %MagikaEx.Result{} = result} = MagikaEx.identify_path(path)

      assert result.group != "archive"
      assert result.group == "executable"
    end

    test "returns error for non-existent file" do
      assert {:error, :enoent} = MagikaEx.identify_path("non_existent_file")
    end
  end
end
