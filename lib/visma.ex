# Copyright (c) 2022 Mathieu Kerjouan
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#  3. Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
