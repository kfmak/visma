defmodule Visma.Types.Recipient do
  @moduledoc false

  defstruct address: nil,
    authentication_method: nil,
    cvr: nil,
    cpr: "",
    email: "",
    id: "",
    name: "",
    pid: nil,
    phone: nil,
    ssn: nil,
    send_distribution_document: nil,
    send_distribution_notification: true,
    send_welcome_notification: true,
    signing_method: 2,
    template_data: %{"Items" => []},
    title: nil,
    tupas_ssn: nil

  @spec new(map()) :: %__MODULE__{}
  def new(map) do
    %__MODULE__{
      address: Map.get(map, :address, nil),
      authentication_method: Map.get(map, :authentication_method, nil),
      cvr: Map.get(map, :cvr, nil),
      cpr: Map.fetch!(map, :cpr),
      email: Map.get(map, :email, ""),
      id: Map.get(map, :id, Ecto.UUID.generate()),
      name: Map.fetch!(map, :name),
      pid: Map.get(map, :pid, nil),
      phone: Map.get(map, :phone, nil),
      ssn: Map.get(map, :ssn, nil),
      send_distribution_document: Map.get(map, :send_distribution_document, nil),
      send_distribution_notification: Map.get(map, :send_distribution_notification, true),
      send_welcome_notification: Map.get(map, :send_welcome_notification, true),
      signing_method: Map.get(map, :signing_method, 2),
      template_data: Map.get(map, :template_data, %{"Items" => []}),
      title: Map.get(map, :title, nil),
      tupas_ssn: Map.get(map, :tupas_ssn, nil)
    }
  end

  @spec to_map(%__MODULE__{}) :: map()
  def to_map(%__MODULE__{} = recipient) do
    %{
      "Address" => recipient.address,
      "AuthenticationMethod" => recipient.authentication_method,
      "CVR" => recipient.cvr,
      "Cpr" => recipient.cpr,
      "Email" => recipient.email,
      "Id" => recipient.id,
      "Name" => recipient.name,
      "PID" => recipient.pid,
      "Phone" => recipient.phone,
      "SSN" => recipient.ssn,
      "SendDistributionDocument" => recipient.send_distribution_document,
      "SendDistributionNotification" => recipient.send_distribution_notification,
      "SendWelcomeNotification" => recipient.send_welcome_notification,
      "SigningMethod" => recipient.signing_method,
      "TemplateData" => recipient.template_data,
      "Title" => recipient.title,
      "TupasSsn" => recipient.tupas_ssn
    }
  end
end
