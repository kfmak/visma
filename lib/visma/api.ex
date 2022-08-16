defmodule Visma.Api do
  @moduledoc """
  Visma API Elixir implementation. This module offers a way to
  play with visma API. It has been tested on the demo API, and
  should work as well on the main one. This is a low level
  interface, you should probably use other module to directly
  craft the correct request.
  """

  @type campaign_name() :: String.t()
  @type document() :: map()
  @type documents() :: [document(), ...]
  @type email() :: String.t()
  @type group_id() :: Ecto.UUID.t()
  @type group_name() :: String.t()
  @type name() :: String.t()
  @type options() :: Keyword.t()
  @type password() :: String.t()
  @type recipient() :: map()
  @type recipients() :: [recipient(), ...]
  @type sender() :: Visma.Api.Types.Sender.sender()
  @type signing_token() :: Ecto.UUID.t()
  @type template_id() :: Ecto.UUID.t()
  @type token() :: Ecto.UUID.t()
  @type transaction_token() :: Ecto.UUID.t()
  @type user_name() :: String.t()

  defstruct [
    base_url: "",
    api_path: "",
    full_url: :undefined,
    query: %{},
    method: :undefined,
    headers: [],
    body: %{},
    token_required: true,
    token: :undefined,
    token_in_body: false
  ]

  @doc """
  Initialize a new Visma.Api data-structure used to
  generate request. By default, the `base_url` key
  is initialized using environment but it can be
  bypassed by using new/1 function.

  TODO: sanitize base_url field

  ## Examples

    iex> Visma.Api.new()

    iex> Visma.Api.new(base_url: "http://my-url.com/api")

  """
  @spec new() :: %__MODULE__{}
  def new(), do: new(base_url: base_url())

  @spec new(Keyword.t()) :: %__MODULE__{}
  def new(opts) do
    with base_url <- Keyword.fetch!(opts, :base_url)
    do
      %__MODULE__{base_url: base_url}
    end
  end

  @doc """
  Log to Visma API using email and password as credentials. A
  valid connection returns a token. Be careful, the token has
  a limited lifetime, if you are reusing it, you should ensure
  it is still valid.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#563cb993-f2f6-4ca2-b8e7-7d61c240e714

  ## example

  Simple example, change with the correctly values.

      iex> api = Visma.Api.new()
      iex> request = Visma.Api.login(api,
        email: "foo@bar.com",
        password: "my_password"
      )
      iex> prepared_request = Visma.Api.prepare(request)
      iex> Visma.Api.send(prepared_request)
      {:ok, "00000000-0000-0000-0000-000000000000"}

  A Working example with demo credentials from official. It will
  return a valid token.

      iex> api = Visma.Api.new(base_url: "https://demo.vismaaddo.net/WebService/v2.0/restsigningservice.svc")
      iex> request = Visma.Api.login(api,
        email: "fake.email.for.api.test@visma.com",
        password: Base.decode64!("c/SjPSMTRcZW1yzcvs6qdUOrnx4GyHoH0fyD0h9XnAAYP7PP/sNgTjKDMSUGlZAXB+ZFmm20JWK6hrsgJHsGYw=="),
        password_is_base64: true)
      )
      iex> Visma.Api.send(request)
      {:ok, "00000000-0000-0000-0000-000000000000"}

  Using an invalid email

      iex> api = Visma.Api.new()
      iex> request = Visma.Api.login(api,
        email: "invalid@email.com",
        password: "test"
      )
      iex> Visma.Api.send(request)
      {:error, [%{"FaultCode" => 900, "Reason" => "Invalid email"}]}
  """
  @type login_arguments() :: [email: email(), password: password()] | Keyword.t()
  @spec login(%__MODULE__{}, login_arguments())
  :: %__MODULE__{}

  def login(%__MODULE__{} = api, args) do
    with email <- Keyword.fetch!(args, :email),
      password <- Keyword.fetch!(args, :password),
      password_base64 <- Base.encode64(password)
    do
      %{api|
        method: :post,
        api_path: "login",
        token_required: false,
        headers: [{"Content-Type", "application/json"}],
        body: %{"email" => email, "password" => password_base64}
      }
    end
  end

  @doc """
  Similar than login/2 except it requires a token to be
  set.

  ## Examples

      iex> api = Visma.Api.new()
      iex> request = Visma.Api.login(api,
        email: "foo@bar.com",
        password: "my_password"
      )
      iex> prepared_request = Visma.Api.prepare(request, token: token)
      iex> Visma.Api.send(prepared_request)
      {:ok, "00000000-0000-0000-0000-000000000000"}

  """
  @spec login2(%__MODULE__{}, login_arguments())
  :: %__MODULE__{}

  def login2(%__MODULE__{} = api, args) do
    with email <- Keyword.fetch!(args, :email),
      password <- Keyword.fetch!(args, :password),
      password_base64 <- Base.encode64(password)
    do
      %{api|
        method: :post,
        api_path: "login",
        token_required: true,
        token_in_body: true,
        headers: [{"Content-Type", "application/json"}],
        body: %{"email" => email, "password" => password_base64}
      }
    end
  end

  @doc """
  Returns a signing template available. A signing template
  is needed when using initiate_signing/2 function. Choose
  one method, and extract its `id`.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#383ab277-6264-4847-9e6f-32b41670733d

  ## example

      iex> api = Visma.Api.new()
      iex> request = Visma.Api.get_signing_templates(api, token: "my_token")
      iex> Visma.Api.send(request)
      {:ok, %{ "SigningTemplateItems" => templates }}
  """
  @spec get_signing_templates(%__MODULE__{})
  :: %__MODULE__{}

  def get_signing_templates(%__MODULE__{} = api) do
    %{api|
      method: :get,
      api_path: "GetSigningTemplates",
      token_required: true,
      token_in_body: false
    }
  end

  @doc """
  This function initiate a signing procedure by sending
  information about a sender, a list of recipients and a
  list of document.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#71c7e5fd-0239-4bf8-ab5a-93f38a12aa4c

  ## example

      iex> signing = Visma.Signing.new()
      iex> signing = Visma.Signing.request(signing,
        signing_template_id: "template_id"
      )
      iex> signing = Visma.Signing.sender(signing, ...)
      iex> signing = Visma.Signing.document(signing, ...)
      iex> signing = Visma.Signing.recipient(signing, ...)
      iex> signing_map = Visma.Signing.to_map(signing)
      iex> api = Visma.Api.new()
      iex> request = Visma.Api.initiate_signing(api,
        token: "my-token",
        signing_request: signing_map
      )
      iex> Visma.Api.send(request)
  """
  @type initiate_signing_arguments() :: [signing_request: map()]
  @spec initiate_signing(%__MODULE__{}, initiate_signing_arguments())
  :: %__MODULE__{}

  def initiate_signing(%__MODULE__{} = api, args) do
    with signing <- Keyword.fetch!(args, :signing_request)
    do
      %{api|
        method: :post,
        api_path: "InitiateSigning",
        headers: [{"Content-Type", "application/json"}],
        token_required: true,
        token_in_body: true,
        body: %{"request" => signing}
      }
    end
  end

  @doc """
  Get signing state of a specific signature.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#7893bed4-4e05-4cdb-902c-661c2440ed8e

  ## Examples

      iex> api = Visma.Api.new()
      iex> request = Visma.Api.get_signing_arguments(token: "my-token", signing_token: "my-signing-token")
      iex> Visma.Api.send(request)
  """
  @type get_signing_arguments() :: [signing_token: signing_token()]
  @spec get_signing(%__MODULE__{}, get_signing_arguments)
  :: %__MODULE__{}

  def get_signing(%__MODULE__{} = api, args) do
    with signing_token <- Keyword.fetch!(args, :signing_token)
    do
      %{api|
        method: :get,
        api_path: "GetSigning",
        token_required: true,
        token_in_body: false,
        query: %{"signingToken" => signing_token},
      }
    end
  end

  @doc """
  Get the signing status of each documents. A transaction id
  is associated with each of them, and can be cancelled with
  cancel_transaction/2 function.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#f4e61e46-c91a-4470-8ada-fbb21085db45

  ## Examples
  """
  @type get_signing_status_arguments() :: [signing_token: signing_token()]
  @spec get_signing_status(%__MODULE__{}, get_signing_status_arguments())
  :: %__MODULE__{}

  def get_signing_status(%__MODULE__{} = api, args) do
    with signing_token <- Keyword.fetch!(args, :signing_token)
    do
      %{api|
        method: :get,
        api_path: "GetSigningStatus",
        token_required: true,
        token_in_body: false,
        query: %{"signingToken" => signing_token}
      }
    end
  end

  @doc """
  Initiate a new campaign.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#233559d9-1668-4c10-8c6b-cbb87276b58f

  ## Examples
  """
  @type initiate_campaign_arguments() :: [
    signing_template_id: Ecto.UUID.t(),
    recipients: [],
    site: String.t(),
    transaction_state_change_url: String.t(),
    last_reminder: integer(),
    signing_method: integer()
  ]
  @spec initiate_campaign(%__MODULE__{}, initiate_campaign_arguments())
  :: %__MODULE__{}

  def initiate_campaign(%__MODULE__{} = api, args) do
    with name <- Keyword.fetch!(args, :name),
      signing_template_id <- Keyword.fetch!(args, :signing_template_id),
      recipients <- Keyword.fetch!(args, :recipients),
      site <- Keyword.get(args, :site, ""),
      transaction_state_change_url <- Keyword.get(args, :transaction_state_change_url, nil),
      last_reminder <- Keyword.get(args, :last_reminder, 1),
      signing_method <- Keyword.get(args, :signing_method, 1)
    do
      %{api|
        method: :post,
        api_path: "InitiateCampaign",
        headers: [{"Content-Type", "application/json"}],
        token_required: true,
        token_in_body: true,
        body: %{
          "request" => %{
            "Name" => name,
            "Site" => site,
            "SigningTemplateId" => signing_template_id,
            "TransactionStateChangeUrl" => transaction_state_change_url,
            "Recipients" => recipients,
          },
          "templateOverride" => %{
            "LastReminder" => last_reminder,
            "SigningMethod" => signing_method
          }
        }
      }
    end
  end

  @doc """
  Cancel a transaction. The transaction id can be found with
  get_signing_status/2 function.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#97f933ae-2da5-44cf-98e2-612fa95bf0ae

  ## Examples
  """
  @type cancel_transaction_arguments() :: [transaction_token: token()]
  @spec cancel_transaction(%__MODULE__{}, cancel_transaction_arguments())
  :: %__MODULE__{}

  def cancel_transaction(%__MODULE__{} = api, args) do
    with transaction_token <- Keyword.fetch!(args, :transaction_token)
      do
        %{api|
          method: :post,
          api_path: "CancelTransaction",
          headers: [{"Content-Type", "application/json"}],
          token_required: true,
          token_in_body: true,
          body: %{"transactionToken" => transaction_token}
        }
      end
  end

  @doc """
  Get all running campaigns.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#d8dd97cf-dd49-4737-957d-442718a99b05

  ## Examples
  """
  @type get_campaigns_arguments() :: [reference: token()]
  @spec get_campaigns(%__MODULE__{}, get_campaigns_arguments())
  :: %__MODULE__{}

  def get_campaigns(%__MODULE__{} = api, args) do
    with reference <- Keyword.fetch!(args, :reference)
    do
      %{api|
        method: :post,
        api_path: "GetCampaigns",
        headers: [{"Content-Type", "application/json"}],
        token_required: true,
        token_in_body: true,
        body: %{"externalReference" => reference}
      }
    end
  end

  @doc """
  TODO: not tested yet.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#e32a8a09-902c-4b43-bb99-c784fe010299

  ## Examples
  """
  @type get_template_messages_arguments() :: [template_id: Ecto.UUID.t()]
  @spec get_template_messages(%__MODULE__{}, Keyword.t())
  :: %__MODULE__{}

  def get_template_messages(%__MODULE__{} = api, args) do
    with template_id <- Keyword.fetch!(args, :template_id)
    do
      %{api|
        method: :get,
        api_path: "GetTemplateMessages",
        token_required: true,
        token_in_body: false,
        query: %{"templateId" => template_id}
      }
    end
  end

  @doc """
  TODO: not tested yet.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#57a67bc6-3680-41e7-ba3b-01044b8482db

  ## Examples
  """
  @type get_rejection_comment_arguments() :: [signing_token: signing_token()]
  @spec get_rejection_comment(%__MODULE__{}, get_rejection_comment_arguments())
  :: %__MODULE__{}

  def get_rejection_comment(%__MODULE__{} = api, args) do
    with signing_token <- Keyword.fetch!(args, :signing_token)
    do
      %{api|
        method: :get,
        api_path: "GetRejectionComment",
        token_required: true,
        token_in_body: false,
        query: %{"signingToken" => signing_token}
      }
    end
  end

  @doc """
  TODO: not tested yet.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#a8f2fa53-7d8f-4e5b-97b9-34bb1c232dd6

  ## Examples
  """
  @type create_group_arguments() :: [
    name: String.t(),
    description: String.t()
  ]
  @spec create_group(%__MODULE__{}, create_group_arguments())
  :: %__MODULE__{}

  def create_group(%__MODULE__{} = api, args) do
    with name <- Keyword.fetch!(args, :name),
      description <- Keyword.get(args, :description, "")
    do
      %{api|
        method: :post,
        api_path: "CreateGroup",
        headers: [{"Content-Type", "application/json"}],
        token_required: true,
        token_in_body: true,
        body: %{
          "request" => %{
            "Name" => name,
            "Description" => description
          }
        }
      }
    end
  end

  @doc """
  TODO: not tested yet.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#7720dbe8-cd53-4d6a-9bc2-ce43aab28b82

  ## Examples
  """
  @spec get_groups(%__MODULE__{}) :: %__MODULE__{}

  def get_groups(%__MODULE__{} = api) do
    %{api|
      method: :get,
      api_path: "GetGroups",
      token_required: true,
      token_in_body: false,
      query: %{}
    }
  end

  @doc """
  TODO: not tested yet.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#ab6343f6-c77b-4b38-a0f8-5d04014bfb08

  ## Examples
  """
  @type create_user_arguments() :: [
    email: email(),
    language_id: integer(),
    phone: String.t(),
    role_id: integer(),
    send_welcome_email: boolean()
  ]
  @spec create_user(%__MODULE__{}, create_user_arguments())
  :: %__MODULE__{}

  def create_user(%__MODULE__{} = api, args) do
    with name <- Keyword.fetch!(args, :name),
      email <- Keyword.fetch!(args, :email),
      language_id <- Keyword.get(args, :language_id, 2),
      phone <- Keyword.get(args, :phone, ""),
      role_id <- Keyword.get(args, :role_id, 3),
      send_welcome_email <- Keyword.get(args, :send_welcome_email, false)
    do
      %{api|
        method: :post,
        api_path: "CreateUser",
        headers: [{"Content-Type", "application/json"}],
        token_required: true,
        token_in_body: true,
        body: %{
          "request" => %{
            "Email" => email,
            "FullName" => name,
            "LanguageId" => language_id,
            "Phone" => phone,
            "RoleId" => role_id,
            "SendWelcomeEmail" => send_welcome_email
          }
        }
      }
    end
  end

  @doc """
  TODO: not tested yet.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#069afa57-89d7-4738-921b-d369570bd2e0

  ## Examples
  """
  @type add_user_to_group_arguments() :: [
    email: email(),
    group_id: integer() # TODO: check required
  ]
  @spec add_user_to_group(%__MODULE__{}, add_user_to_group_arguments())
  :: %__MODULE__{}

  def add_user_to_group(%__MODULE__{} = api, args) do
    with email <- Keyword.fetch!(args, :email),
      group_id <- Keyword.fetch!(args, :group_id)
    do
      %{api|
        method: :post,
        api_path: "AddUserToGroup",
        headers: [{"Content-Type", "application/json"}],
        token_required: true,
        token_in_body: true,
        body: %{
          "request" => %{
            "Email" => email,
            "GroupId" => group_id
          }
        }
      }
    end
  end

  @doc """
  TODO: not tested yet.

  - see: https://documenter.getpostman.com/view/4950720/RWMLJkeo#a878b950-fe29-4610-b68f-94fcf3e530c9

  ## Examples
  """
  @type cancel_signing_arguments() :: [signing_token: signing_token()]
  @spec cancel_signing(%__MODULE__{}, cancel_signing_arguments()) :: %__MODULE__{}
  def cancel_signing(%__MODULE__{} = api, args) do
    with signing_token <- Keyword.fetch!(args, :signing_token)
    do
      %{api|
        method: :post,
        api_path: "CancelSigning",
        headers: [{"Content-Type", "application/json"}],
        token_required: true,
        token_in_body: true,
        body: %{
          "signingToken" => signing_token
        }
      }
    end
  end

  @spec prepare2(%__MODULE__{}) :: %__MODULE__{}
  defp prepare2(%__MODULE__{base_url: base_url, api_path: api_path, query: query} = api) do
    with url <- Path.join([base_url, api_path]),
      encoded_query <- URI.encode_query(query)
    do
      case query do
        [] -> %{api| full_url: url}
        _ when query == %{} -> %{api| full_url: url}
        _ -> %{api| full_url: Enum.join([url, encoded_query], "?")}
      end
    end
  end

  @doc """
  Prepare a request by adding a token or any mandatory
  elements.
  """
  @spec prepare(%__MODULE__{}, Keyword.t()) :: %__MODULE__{}
  def prepare(api), do: prepare(api, [])
  def prepare(%__MODULE__{token_required: false} = api, _args), do: prepare2(api)
  def prepare(%__MODULE__{token_required: true} = api, args) do
    with token <- Keyword.fetch!(args, :token)
    do
      case api.token_in_body do
        true -> prepare2(%{api|
          token: token,
          body: Map.put(api.body, "Token", token)
        })
        false -> prepare2(%{api|
          token: token,
          query: Map.put(api.query, "Token", token)
        })
      end
    end
  end

  @doc """
  Send a request and wait for its response. It automatically
  uses prepare/1 function to prepare the request. Reponse is
  parsed using parse_response/1 internal function.
  """
  @spec send(%__MODULE__{}) :: {:ok, any()} | {:error, any()}
  def send(%__MODULE__{method: :get} = api), do: send_get(api)
  def send(%__MODULE__{method: :post} = api), do: send_post(api)
  def send(%__MODULE__{method: method}), do: {:error, {:unknown_method, method}}

  @spec send_post(%__MODULE__{}) :: {:ok, any()} | {:error, any()}
  defp send_post(%__MODULE__{full_url: url, headers: headers, body: body}) do
    with {:ok, payload_json} <- Jason.encode(body),
      {:ok, response} <- HTTPoison.post(url, payload_json, headers)
    do
      parse_response(response)
    end
  end

  @spec send_get(%__MODULE__{}) :: {:ok, any()} | {:error, any()}
  defp send_get(%__MODULE__{full_url: url, headers: headers}) do
    with {:ok, response} <- HTTPoison.get(url, headers) do
      parse_response(response)
    end
  end

  @spec parse_response(map())
  :: {:ok, any()} | {:error, any()}
  defp parse_response(%{body: body, status_code: 200}), do: Jason.decode(body)
  defp parse_response(%{body: body}) do
    with {:ok, error} <- Jason.decode(body) do
      {:error, error}
    end
  end

  @spec base_url() :: String.t()
  defp base_url() do
    Application.get_env(:visma, :base_url, "https://demo.vismaaddo.net/WebService/v2.0/restsigningservice.svc")
  end
end
