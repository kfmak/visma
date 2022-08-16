defmodule Visma.Manager do
  @moduledoc """
  Visma API tokens lifetime is short. When using the API, after few minutes of
  usage, an expired token is returned. When dealing with document signature
  we cannot have this kind of error and we find a way to never lose our
  transaction. Visma.Manager was created to always maintain a correct state.

  - TODO: I don't know if each call to the API has a cost. If it's the case
          we should think about it and create a cache somewhere to store
          elements like signing templates or template messages (required in
          other API calls).

  - TODO: token should be stored in an external store like ETS.
          we could then update it without changing the state of the process

  - TODO: what could happen if we lose our document? It should probably
          never happen, so, we should store them somewhere in safe place.
  """
  use GenServer
  require Logger

  defstruct base_url: nil,
    email: nil,
    password: nil,
    token: nil,
    token_created_at: nil,
    token_fail_counter: 0,
    token_fail_counter_limit: 5

  @doc """
  For test or development only. This process will be started
  without being registered.
  """
  def start(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  @doc """
  Automatically start a new process registered as Visma.Manager.
  Only one can be present on the platform.
  """
  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Initialize a new Visma.Manager process, using `email`, `password` and
  `base_url` value from `:visma` application environment.
  """
  @impl true
  def init(_) do
    # we set all elements from environment
    with base_url <- Application.get_env(:visma, :base_url, "https://demo.vismaaddo.net/WebService/v2.0/restsigningservice.svc"),
      token_fail_counter_limit <- Application.get_env(:visma, :token_fail_counter_limit, 5),
      {:ok, email} <- Application.fetch_env(:visma, :email),
      {:ok, password} <- Application.fetch_env(:visma, :password),
      # then we try to get a token from the API, if it fails, we crash.
      {:ok, token} <- call_login(email, password),
      token_created_at <- DateTime.utc_now()
    do
      # if we have a token, we assume credentials are okay, then we
      # start our server with a clean state.
      {:ok,
        %__MODULE__{
          base_url: base_url,
          email: email,
          password: password,
          token: token,
          token_created_at: token_created_at,
          token_fail_counter_limit: token_fail_counter_limit
        }
      }
    else
      error -> Logger.error("#{inspect __MODULE__} process #{inspect self()} crashed with #{inspect error}")
    end
  end

  #---------------------------------------------------------------------
  # Public handler functions
  #---------------------------------------------------------------------

  @impl true
  def handle_call(:get_token, _from, %{token: token} = state), do: {:reply, token, state}
  def handle_call(function, _from, state), do: exec(:call, function, state)

  #---------------------------------------------------------------------
  # Internal privates functions
  #---------------------------------------------------------------------

  defp call_login(email, password) do
    Visma.Api.new()
    |> Visma.Api.login(email: email, password: password)
    |> Visma.Api.prepare([])
    |> Visma.Api.send()
  end

  @spec call_get_signing_templates(%__MODULE__{}) :: {:ok, any()} | {:error, any()}
  defp call_get_signing_templates(%__MODULE__{token: token} ) do
    Visma.Api.new()
    |> Visma.Api.get_signing_templates()
    |> Visma.Api.prepare(token: token)
    |> Visma.Api.send()
  end

  @spec exec(:call | :cast, term(), %__MODULE__{}) :: term()
  defp exec(:call = method, :get_signing_templates = function, state) do
    case call_get_signing_templates(state) do
      {:ok, %{"SigningTemplateItems" => result}} ->
        {:reply, {:ok, result}, state}
      {:error, reason} ->
        handle_errors(method, function, reason, state)
    end
  end
  defp exec(:call = method, :get_signing_templates_by_id = function, state) do
    case call_get_signing_templates(state) do
      {:ok, %{"SigningTemplateItems" => result}} ->
        ids = Enum.map(result, fn(%{"Id" => id} = template) ->
          %{id: id, signing_template: template}
        end)
        {:reply, {:ok, ids}, state}
      {:error, reason} ->
        handle_errors(method, function, reason, state)
    end
  end
  defp exec(:call = method, :get_signing_templates_by_name = function, state) do
    case call_get_signing_templates(state) do
      {:ok, %{"SigningTemplateItems" => result}} ->
        names = Enum.map(result, fn(%{"FriendlyName" => name} = template) ->
          %{name: name, signing_template: template}
        end)
        {:reply, {:ok, names}, state}
      {:error, reason} ->
        handle_errors(method, function, reason, state)
    end
  end
  defp exec(:call = method, {:get_signing_status, id} = function, %__MODULE__{token: token} = state) do
    case Visma.Api.new()
    |> Visma.Api.get_signing_status(token: token, signing_token: id)
    |> Visma.Api.send()
    do
      {:ok, result} ->
        {:reply, {:ok, result}, state}
      {:error, reason} ->
        handle_errors(method, function, reason, state)
    end
  end
  defp exec(:call = method, {:cancel_transaction, id} = function, %__MODULE__{token: token} = state) do
    case Visma.Api.new()
    |> Visma.Api.cancel_transaction(token: token, transaction_token: id)
    |> Visma.Api.send()
    do
      {:ok, result} ->
        {:reply, {:ok, result}, state}
      {:error, reason} ->
        handle_errors(method, function, reason, state)
    end
  end
  defp exec(:call = method, {:dispatch, api} = struct, %__MODULE__{token: token} = state) do
    case api
    |> Visma.Api.prepare(token: token)
    |> Visma.Api.send() do
      {:ok, result} ->
        {:reply, {:ok, result}, state}
      {:error, reason} ->
        handle_errors(method, struct, reason, state)
    end
  end

  @spec handle_errors(:call | :cast, term(), term(), %__MODULE__{}) :: term()
  # after 5 token failure, we stop the execution of the process and return the
  # function/reason of the problem.
  defp handle_errors(:call, function, reason, %__MODULE__{token_fail_counter: x, token_fail_counter_limit: x} = state) do
    Logger.error("#{inspect __MODULE__} cannot generate a valid token")
    {:stop, :invalid_credentials_or_token, {:error, {:invalid_credentials_or_token}, function, reason}, state}
  end
  # To be used with cast handlers.
  # defp handle_errors(:cast, _function, _reason, %{token_fail_counter: 5} = state) do
  #   {:stop, :invalid_credentials_or_token, state}
  # end
  defp handle_errors(:call, _function, %Jason.DecodeError{}, state) do
    {:reply, :request_error, state}
  end
  defp handle_errors(method, function, %{"FaultCode" => 101, "Reason" => "Invalid Token"}, state) do
    invalid_token_reload(method, function, state)
  end
  defp handle_errors(method, function, {:error, %{"FaultCode" => 102, "Reason" => "Token Expired"}}, state) do
    invalid_token_reload(method, function, state)
  end
  defp handle_errors(method, function, _reason, state) do
    invalid_token_reload(method, function, state)
  end

  @spec invalid_token_reload(:call | :cast, term(), %__MODULE__{}) :: term()
  defp invalid_token_reload(method, function, state) do
    with email <- Map.fetch!(state, :email),
      password <- Map.fetch!(state, :password),
      {:ok, token} <- call_login(email, password),
      token_created_at <- DateTime.utc_now()
    do
      Logger.info("#{inspect __MODULE__} generate a new token (#{inspect token_created_at})")
      exec(method, function, %{state|
        token: token,
        token_created_at: token_created_at,
        token_fail_counter: (state.token_fail_counter + 1)
      })
    end
  end

  #---------------------------------------------------------------------
  # Interfaces
  #---------------------------------------------------------------------

  @doc """
  Call interface to get a token.
  """
  @spec get_token() :: {:ok, String.t()}
  def get_token(), do: GenServer.call(__MODULE__, :get_token)

  @doc """
  Call interface to get the complete list of all signing templates
  available.
  """
  @spec get_signing_templates() :: {:ok, map()}
  def get_signing_templates(), do: GenServer.call(__MODULE__, :get_signing_templates)

  @doc """
  Call interface to get the signing templates names (also defined
  as FriendlyName).
  """
  @spec get_signing_templates_by_name() :: any()
  def get_signing_templates_by_name(), do: GenServer.call(__MODULE__, :get_signing_templates_by_name)

  @doc """
  Call interface to get the signing templates id.
  """
  @spec get_signing_templates_by_id() :: any()
  def get_signing_templates_by_id(), do: GenServer.call(__MODULE__, :get_signing_templates_by_id)

  @doc """
  Call interface to get a signing status.
  """
  @spec get_signing_status(String.t()) :: any()
  def get_signing_status(id), do: GenServer.call(__MODULE__, {:get_signing_status, id})

  @doc """
  Call interface to cancel a transaction.
  """
  @spec cancel_transaction(String.t()) :: any()
  def cancel_transaction(id), do: GenServer.call(__MODULE__, {:cancel_transaction, id})

  @doc """
  Send a Visma data-structure to Visma.Manager process
  and wait for the response.
  """
  def dispatch(%Visma.Api{} = api), do: GenServer.call(__MODULE__, {:dispatch, api})

end
