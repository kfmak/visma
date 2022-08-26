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

defmodule Visma.SigningTest do
  use ExUnit.Case

  test "create a new signing request" do
    signing_request = Visma.Signing.new()
    |> Visma.Signing.request(
      name: "new signing request",
      signing_template_id: "00000000-0000-0000-0000-000000000000",
      reference_number: "12346"
    )
    |> Visma.Signing.sender(
      email: "sender@foobar.com",
      name: "sender name",
      company_name: "company name"
    )
    |> Visma.Signing.recipient(
      name: "recipient name",
      cpr: "1234567890",
      email: "recipient@foobar.com"
    )
    |> Visma.Signing.recipients([
      [
        name: "recipient name 2",
        cpr: "1234567892",
        email: "recipient2@foobar.com"
      ]
    ])
    |> Visma.Signing.document(
      name: "test.pdf",
      mime_type: "application/pdf",
      data: "pdf content here"
    )
    |> Visma.Signing.documents([
      [
        name: "test1.pdf",
        mime_type: "application/pdf",
        data: "pdf content here 1"
      ]
    ])

    signing_request_map = Visma.Signing.to_map(signing_request)

    # check mandatory request parameters
    assert signing_request.name == "new signing request"
    assert signing_request.signing_template_id == "00000000-0000-0000-0000-000000000000"
    assert signing_request.reference_number == "12346"
    assert signing_request_map["Name"] == "new signing request"
    assert signing_request_map["SigningTemplateId"] == "00000000-0000-0000-0000-000000000000"
    assert signing_request_map["SigningData"]["ReferenceNumber"] == "12346"

    # check sender
    sender_map = signing_request_map["SigningData"]["Sender"]
    assert signing_request.sender.name == "sender name"
    assert signing_request.sender.email == "sender@foobar.com"
    assert signing_request.sender.company_name == "company name"
    assert sender_map["Name"] == "sender name"
    assert sender_map["Email"] == "sender@foobar.com"
    assert sender_map["CompanyName"] == "company name"

    # check if the recipient is present
    recipients_map = signing_request_map["SigningData"]["Recipients"]
    assert List.last(signing_request.recipients).name == "recipient name"
    assert List.last(recipients_map)["Name"] == "recipient name"
    assert List.last(signing_request.recipients).cpr == "1234567890"
    assert List.last(recipients_map)["Cpr"] == "1234567890"
    assert List.last(signing_request.recipients).email == "recipient@foobar.com"
    assert List.last(recipients_map)["Email"] == "recipient@foobar.com"

    # check if the documents are present
    documents_map = signing_request_map["SigningData"]["Documents"]
    assert List.first(signing_request.documents).name == "test1.pdf"
    assert List.first(documents_map)["Name"] == "test1.pdf"
    assert List.last(signing_request.documents).name == "test.pdf"
    assert List.last(documents_map)["Name"] == "test.pdf"

    # check json format
    {:ok, signing_request_json} = Visma.Signing.to_json(signing_request)
    assert Jason.decode!(signing_request_json)["Name"] == "new signing request"
  end
end
