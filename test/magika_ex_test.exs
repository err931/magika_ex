defmodule MagikaEx.NativeTest do
  use ExUnit.Case
  doctest MagikaEx.Native

  test "greets the world" do
    assert MagikaEx.Native.add(1, 2) == 3
  end
end
