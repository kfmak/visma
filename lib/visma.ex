defmodule Visma do
  @moduledoc """
  Visma module is the main interface used to communicate with visma API.
  It required to have `:visma` application started and a valid configuration
  in `config/config.exs`
  """

  @doc """
  Dispatch a Visma data-structure to Visma.Manager.

  ## Examples

      iex> api = Visma.Api.new()
      iex> request = Visma.Api.get_signing_templates(api)
      iex> Visma.dispatch(request)
  """
  @spec dispatch(Visma.Api.t()) :: {:ok, any()} | {:error, any()}
  def dispatch(%Visma.Api{} = api), do: Visma.Manager.dispatch(api)

  @doc """
  Take a Visma.Signing data-structures and send it to the API, only
  using Visma.Manager to get a token.
  """
  @spec deliver(Visma.Signing.t()) :: {:ok, any()} | {:error, any()}
  def deliver(%Visma.Signing{} = signing) do
    with token <- Visma.Manager.get_token(),
      signing_map <- Visma.Signing.to_map(signing)
    do
      Visma.Api.new()
      |> Visma.Api.initiate_signing(signing_request: signing_map)
      |> Visma.Api.prepare(token: token)
      |> Visma.Api.send()
    end
  end
end
