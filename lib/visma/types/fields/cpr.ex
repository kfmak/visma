defmodule Visma.Types.Field.Cpr do
  @moduledoc false

  @spec is_valid?(String.t()) :: boolean()
  def is_valid?(cpr) do
    Regex.match?(~r/^[0-9]{10}$/, cpr)
  end

  @spec is_valid(String.t()) :: {:ok, String.t()} | {:error, term()}
  def is_valid(cpr) do
    case is_valid?(cpr) do
      true -> {:ok, cpr}
      false -> {:error, :invalid_cpr}
    end
  end
end
