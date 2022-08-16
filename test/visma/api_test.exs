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

defmodule Visma.ApiTest do
  use ExUnit.Case

  # TODO: mock the interfaces using a local service
  # TODO: ensure the values passed are correct

  @token "00000000-0000-0000-0000-000000000000"

  test "overwrite base_url locally" do
    request = Visma.Api.new(base_url: "http://localhost:8080/")

    assert request.base_url == "http://localhost:8080/"
  end

  test "login with credentials" do
    request = Visma.Api.new()
    |> Visma.Api.login(
      email: "test@test.com",
      password: "my-password"
    )
    |> Visma.Api.prepare([])

    assert request.body["email"] == "test@test.com"
    assert request.body["password"] == Base.encode64("my-password")
    assert request.token_required == false
  end

  test "login with credentials and token" do
    request = Visma.Api.new()
    |> Visma.Api.login2(
      email: "test@test.com",
      password: "my-password"
    )
    |> Visma.Api.prepare(token: @token)

    assert request.body["email"] == "test@test.com"
    assert request.body["password"] == Base.encode64("my-password")
    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == true
    assert request.body["Token"] == @token
  end

  test "get available signing templates" do
    request = Visma.Api.new()
    |> Visma.Api.get_signing_templates()
    |> Visma.Api.prepare(token: @token)

    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == false
    assert request.query["Token"] == @token
  end

  test "get signing with defined signing token" do
    request = Visma.Api.new()
    |> Visma.Api.get_signing(
      signing_token: "00000000-0000-0000-0000-000000000000"
    )
    |> Visma.Api.prepare(token: @token)

    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == false
    assert request.query["Token"] == @token
  end

  test "get signing status with defined signing token" do
    request = Visma.Api.new()
    |> Visma.Api.get_signing_status(
      signing_token: "00000000-0000-0000-0000-000000000000"
    )
    |> Visma.Api.prepare(token: @token)

    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == false
    assert request.query["Token"] == @token
  end

  test "initate a new signing request" do
    # 1. create the signing request first
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
    |> Visma.Signing.document(
      name: "test.pdf",
      mime_type: "application/pdf",
      data: "pdf content here"
    )
    |> Visma.Signing.to_map()

    # 2. then create the whole request
    request = Visma.Api.new()
    |> Visma.Api.initiate_signing(
      signing_request: signing_request
    )
    |> Visma.Api.prepare(token: @token)

    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == true
    assert request.body["Token"] == @token
  end

  test "cancel a transaction" do
    request = Visma.Api.new()
    |> Visma.Api.cancel_transaction(
      transaction_token: "00000000-0000-0000-0000-000000000000"
    )
    |> Visma.Api.prepare(token: @token)

    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == true
    assert request.body["Token"] == @token
  end

  test "get templates messages" do
    request = Visma.Api.new()
    |> Visma.Api.get_template_messages(
      template_id: "00000000-0000-0000-0000-000000000000"
    )
    |> Visma.Api.prepare(token: @token)

    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == false
    assert request.query["Token"] == @token
  end

  test "cancel a signing" do
    request = Visma.Api.new()
    |> Visma.Api.cancel_signing(
      signing_token: "00000000-0000-0000-0000-000000000000"
    )
    |> Visma.Api.prepare(token: @token)

    assert request.token == @token
    assert request.token_required == true
    assert request.token_in_body == true
    assert request.body["Token"] == @token
  end
end
