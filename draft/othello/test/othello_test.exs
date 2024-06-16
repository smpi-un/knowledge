defmodule OthelloTest do
  use ExUnit.Case
  doctest Othello

  test "greets the world" do
    assert Othello.hello() == :world
  end
end
