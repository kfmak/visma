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

defmodule Visma.Types.Document do
  @moduledoc false

  defstruct name: "",
    data: "",
    id: "",
    is_shared: false,
    mime_type: ""

  @spec new(map()) :: %__MODULE__{}
  def new(map) do
    with name <- Map.fetch!(map, :name),
      data <- Map.fetch!(map, :data) |> Base.encode64(),
      id <- Map.get(map, :id, Ecto.UUID.generate()),
      is_shared <- Map.get(map, :is_shared, false),
      mime_type <- Map.get(map, :mime_type, "application/pdf")
    do
      %__MODULE__{
        name: name,
        data: data,
        id: id,
        is_shared: is_shared,
        mime_type: mime_type
      }
    end
  end

  @spec to_map(%__MODULE__{}) :: map()
  def to_map(%__MODULE__{} = document) do
    %{
      "Name" => document.name,
      "Id" => document.id,
      "IsShared" => document.is_shared,
      "MimeType" => document.mime_type,
      "Data" => document.data
    }
  end
end
