defmodule Visma.Signing do
  @moduledoc """
  A more Elixir way to deal with API based on
  one data-structure updated with some functions. The final
  data-structure can be converted in map() and/or json() and
  sent into the wire.
  """

  defstruct name: nil,
    signing_template_id: nil,
    document_signed_url: nil,
    distribution_url: nil,
    expiration_url: nil,
    transaction_state_changed_url: nil,
    rejection_url: nil,
    reference_number: nil,
    sender_comment: nil,
    allow_inbound_enclosures: nil,
    allow_recipient_comment: nil,
    bcc_recipients: nil,
    enclosure_documents: nil,
    external_reference_id: nil,
    sender: %Visma.Types.Sender{},
    recipients: [],
    documents: []

  @doc """
  Create a new Visma.Signing data-structure.

  ## Examples

      iex> Visma.Signing.new()
  """
  @spec new(Keyword.t()) :: %__MODULE__{}
  def new(_opts \\ []) do
    %__MODULE__{}
  end

  @doc """
  Update request fields on Visma.Signing data-structure.

  ## Examples

      iex> Visma.Signing.new() |> Visma.Signing.request(name: "test",
        signing_template: "my_signing_template_id",
        reference_number: "my_reference_number")
  """
  # TODO: improve errors return when there is a missing argument.
  @spec request(%__MODULE__{}, Keyword.t(), Keyword.t()) :: %__MODULE__{}
  def request(%__MODULE__{} = signing, args \\ [], _opts \\ []) do
    with name <- Keyword.fetch!(args, :name),
      signing_template_id <- Keyword.fetch!(args, :signing_template_id),
      reference_number <- Keyword.fetch!(args, :reference_number),
      distribution_url <- Keyword.get(args, :distribution_url, nil),
      document_signed_url <- Keyword.get(args, :document_signed_url),
      expiration_url <- Keyword.get(args, :expiration_url, nil),
      transaction_state_changed_url <- Keyword.get(args, :transaction_state_changed_url, nil),
      rejection_url <- Keyword.get(args, :rejection_url, nil),
      sender_comment <- Keyword.get(args, :sender_comment, nil),
      allow_inbound_enclosures <- Keyword.get(args, :allow_inbound_enclosures, true),
      allow_recipient_comment <- Keyword.get(args, :allow_recipient_comment, true),
      bcc_recipients <- Keyword.get(args, :bcc_recipients, []),
      enclosure_documents <- Keyword.get(args, :enclosure_documents, nil),
      external_reference_id <- Keyword.get(args, :external_reference_id, nil)
    do
      %__MODULE__{signing|
        name: name,
        reference_number: reference_number,
        signing_template_id: signing_template_id,
        document_signed_url: document_signed_url,
        distribution_url: distribution_url,
        expiration_url: expiration_url,
        transaction_state_changed_url: transaction_state_changed_url,
        rejection_url: rejection_url,
        sender_comment: sender_comment,
        allow_inbound_enclosures: allow_inbound_enclosures,
        allow_recipient_comment: allow_recipient_comment,
        bcc_recipients: bcc_recipients,
        enclosure_documents: enclosure_documents,
        external_reference_id: external_reference_id
      }
    end
  end

  @doc """
  Update Visma.Signing data-structure with sender information.

  ## Examples

      iex> Visma.Signing.new() |> Visma.Signing.sender(name: "test",
        email: "foo@bar.com")
  """
  @spec sender(%__MODULE__{}, Keyword.t(), Keyword.t()) :: %__MODULE__{}
  def sender(%__MODULE__{} = signing, sender, _opts \\ []) do
    with email <- Keyword.fetch!(sender, :email),
      name <- Keyword.fetch!(sender, :name),
      company_name <- Keyword.get(sender, :company_name, ""),
      phone <- Keyword.get(sender, :phone, "")
    do
      s = Visma.Types.Sender.new(%{
        company_name: company_name,
        name: name,
        email: email,
        phone: phone
      })
      %{signing|sender: s}
    end
  end

  @doc """
  Update Visma.Signing data-structure with a recipient. Multiple
  call to this function can be done, all recipients will be added
  into a list.

  A CPR code must be defined as a string containing 10 digits like
  `1234567890`. If not correctly set, the API will return this error:

      {:error,[
          %{
            "FaultCode" => 900,
            "Reason" => "The field Cpr must be a string or array type with a maximum length of '10'."
          }
      ]}

  TODO: validate each field before sending and during configuration.

  ## Examples

      iex> Visma.Signing.new()
        |> Visma.Signing.recipient(name: "test", cpr: "1234561234")
        |> Visma.Signing.recipient(name: "test2", cpr: "9876511234")
  """
  @spec recipient(%__MODULE__{}, Keyword.t(), Keyword.t()) :: %__MODULE__{}
  def recipient(%__MODULE__{} = signing, recipient, _opts \\ []) do
    with recipients <- Map.get(signing, :recipients, []),
      name <- Keyword.fetch!(recipient, :name),
      cpr_raw <- Keyword.fetch!(recipient, :cpr),
      {:ok, cpr} <- Visma.Types.Field.Cpr.is_valid(cpr_raw),
      address <- Keyword.get(recipient, :address, nil),
      authentication_method <- Keyword.get(recipient, :authentication_method, nil),
      cvr <- Keyword.get(recipient, :cvr, nil),
      email <- Keyword.get(recipient, :email, ""),
      id <- Keyword.get(recipient, :id, Ecto.UUID.generate()),
      pid <- Keyword.get(recipient, :pid, nil),
      phone <- Keyword.get(recipient, :phone, nil),
      ssn <- Keyword.get(recipient, :ssn, nil),
      send_distribution_document <- Keyword.get(recipient, :send_distribution_document, nil),
      send_distribution_notification <- Keyword.get(recipient, :send_distribution_notification, true),
      send_welcome_notification <- Keyword.get(recipient, :send_welcome_notification, true),
      signing_method <- Keyword.get(recipient, :signing_method, 2),
      template_data <- Keyword.get(recipient, :template_data, %{"Items" => []}),
      title <- Keyword.get(recipient, :title, nil),
      tupas_ssn <- Keyword.get(recipient, :tupas_ssn, nil)
    do
      r = Visma.Types.Recipient.new(%{
        name: name,
        cpr: cpr,
        address: address,
        authentication_method: authentication_method,
        cvr: cvr,
        email: email,
        id: id,
        pid: pid,
        phone: phone,
        ssn: ssn,
        send_distribution_document: send_distribution_document,
        send_distribution_notification: send_distribution_notification,
        send_welcome_notification: send_welcome_notification,
        signing_method: signing_method,
        template_data: template_data,
        title: title,
        tupas_ssn: tupas_ssn
      })
      %{signing|recipients: [r|recipients]}
    end
  end

  @doc """
  Update Visma.Signing data-structure with a list of recipients as
  Keyword.t().

  ## Examples

      iex> Visma.Signing.new() |> Visma.Signing.recipients(
        [
          [name: "test", cpr: "123456"],
          [name: "test2", cpr: "987665"]
        ]
      )
  """
  @spec recipients(%__MODULE__{}, [Keyword.t(), ...], Keyword.t()) :: %__MODULE__{}
  def recipients(signing, recipients, opts \\ []) do
    Enum.reduce(recipients, signing, fn(r, signing) ->
      recipient(signing, r, opts)
    end)
  end

  @doc """
  Update Visma.Signing data-structure with a document. Like
  for recipients, many documents can be added and this function
  can be called many times.

  ## Examples

      iex> Visma.Signing.new()
        |> Visma.Signing.document(name: "test.pdf", data: "pdf content")
        |> Visma.Signing.document(name: "test2.pdf", data: "pdf content2")
  """
  @spec document(%__MODULE__{}, Keyword.t(), Keyword.t()) :: %__MODULE__{}
  def document(%__MODULE__{} = signing, document, _opts \\ []) do
    with documents <- Map.get(signing, :documents, []),
      name <- Keyword.fetch!(document, :name),
      data <- Keyword.fetch!(document, :data),
      id <- Keyword.get(document, :id, Ecto.UUID.generate()),
      is_shared <- Keyword.get(document, :is_shared, false),
      mime_type <- Keyword.get(document, :mime_type, "application/pdf")
    do
      d = Visma.Types.Document.new(%{
        name: name,
        data: Base.encode64(data),
        id: id,
        is_shared: is_shared,
        mime_type: mime_type
      })
      %{signing|documents: [d|documents]}
    end
  end

  @doc """
  Update with a list of document as Keyword.t().

  ## Examples

      iex> Visma.Signing.new()
        |> Visma.Signing.documents(
          [
            [name: "test.pdf", data: "pdf content"],
            [name: "test2.pdf", data: "pdf content2]
          ]
        )
  """
  @spec documents(%__MODULE__{}, [Keyword.t(), ...], Keyword.t()) :: %__MODULE__{}
  def documents(signing, documents, opts \\ []) do
    Enum.reduce(documents, signing, fn(d, signing) ->
      document(signing, d, opts)
    end)
  end

  @doc """
  Convert a Visma.Signing data-structure in a map
  with converted values for the official Visma API.
  """
  @spec to_map(%__MODULE__{}, Keyword.t()) :: map()
  def to_map(%__MODULE__{} = signing, _opts \\ []) do
    with {:ok, s} <- Map.fetch(signing, :sender),
      sender <- Visma.Types.Sender.to_map(s),
      {:ok, d} <- Map.fetch(signing, :documents),
      documents <- Enum.map(d, fn(x) -> Visma.Types.Document.to_map(x) end),
      {:ok, r} <- Map.fetch(signing, :recipients),
      recipients <- Enum.map(r, fn(x) -> Visma.Types.Recipient.to_map(x) end)
    do
      %{
        "DistributionUrl" => Map.fetch!(signing, :distribution_url),
        "DocumentSignedUrl" => Map.fetch!(signing, :document_signed_url),
        "ExpirationUrl" => Map.fetch!(signing, :expiration_url),
        "Name" => Map.fetch!(signing, :name),
        "RejectionUrl" => Map.fetch!(signing, :rejection_url),
        "SigningData" => %{
          "Documents" => documents,
          "Recipients" => recipients,
          "Sender" => sender,
          "AllowInboundEnclosures" => Map.fetch!(signing, :allow_inbound_enclosures),
          "AllowRecipientComment" => Map.fetch!(signing, :allow_recipient_comment),
          "BccRecipients" => Map.fetch!(signing, :bcc_recipients),
          "EnclosureDocuments" => Map.fetch!(signing, :enclosure_documents),
          "ExternalReferenceId" => Map.fetch!(signing, :external_reference_id),
          "ReferenceNumber" => Map.fetch!(signing, :reference_number),
          "SenderComment" => Map.fetch!(signing, :sender_comment)
        },
        "SigningTemplateId" => Map.fetch!(signing, :signing_template_id),
        "StartDate" => date(),
        "TransactionStateChangedUrl" => Map.fetch!(signing, :transaction_state_changed_url)
      }
    end
  end

  @doc """
  Convert a Visma.Signing data-structure into a JSON object.
  """
  @spec to_json(%__MODULE__{}, Keyword.t()) :: {:ok, String.t()}
  def to_json(signing, _opts \\ []), do: signing |> to_map() |> Jason.encode()

  defp date() do
    date = DateTime.now!("Etc/UTC")
    |> DateTime.to_unix(:millisecond)
    |> Integer.to_string()
    "/Date(" <> date <> ")/"
  end
end
