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
