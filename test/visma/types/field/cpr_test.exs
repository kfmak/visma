defmodule Visma.Types.Field.CprTest do
  use ExUnit.Case

  test "test valid and wrong cpr number"  do
    assert true == Visma.Types.Field.Cpr.is_valid?("1234567890")
    assert false == Visma.Types.Field.Cpr.is_valid?("abcd1234")
    assert {:ok, "1234567890"} == Visma.Types.Field.Cpr.is_valid("1234567890")
    assert {:error, :invalid_cpr} == Visma.Types.Field.Cpr.is_valid("abcd1234")
  end
end
