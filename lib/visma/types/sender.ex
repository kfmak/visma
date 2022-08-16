defmodule Visma.Types.Sender do
  @moduledoc false

  @type company_name() :: String.t()
  @type email() :: String.t()
  @type name() :: String.t()
  @type phone() :: String.t()

  defstruct company_name: "",
    email: "",
    name: "",
    phone: ""

  @spec new(map()) :: %__MODULE__{}
  def new(map) do
    %__MODULE__{
      company_name: Map.get(map, :company_name, ""),
      email: Map.get(map, :email, ""),
      name: Map.get(map, :name, ""),
      phone: Map.get(map, :phone, "")
    }
  end

  def to_map(%__MODULE__{} = sender) do
    %{
      "CompanyName" => sender.company_name,
      "Email" => sender.email,
      "Name" => sender.name,
      "Phone" => sender.phone
    }
  end
end
