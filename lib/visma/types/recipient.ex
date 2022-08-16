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
