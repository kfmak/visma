defmodule Visma.Types.Fields.Token do
  @moduledoc false

  @spec is_valid?(String.t()) :: boolean()
  def is_valid?(token) do
    # 7983d5bb-7c1e-4e5c-9aed-b8146b681cbd
    Regex.match?(~r/^[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}$/, token)
  end

  @spec is_valid(String.t()) :: {:ok, String.t()} | {:error, term()}
  def is_valid(token) do
    case is_valid?(token) do
      true -> {:ok, token}
      false -> {:error, :invalid_token}
    end
  end
end
