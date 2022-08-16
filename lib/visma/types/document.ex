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
