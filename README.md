# Visma Application

Elixir implementation of Visma API.

## Build

```elixir
mix deps.get
mix compile
```
## Test

```elixir
mix eunit
```

## Configuration

If you are using `Visma.Manager` application, you will
need to configure these elements in `config/config.exs`

```elixir
config :visma,
  base_url: "https://demo.vismaaddo.net/WebService/v2.0/restsigningservice.svc",
  email: "fake.email.for.api.test@visma.com",
  password: Base.decode64!("c/SjPSMTRcZW1yzcvs6qdUOrnx4GyHoH0fyD0h9XnAAYP7PP/sNgTjKDMSUGlZAXB+ZFmm20JWK6hrsgJHsGYw==")
```

## Usage

When started, Visma application start a process called
`Visma.Manager`. This one automatically generate a valid
token and can automatically renew it when sending requests.
The implementation is not complete, all requests are not
managed by this process at the moment.

## High Level Usage (with `Visma.Manager`)

Here some code example to use it with `Visma.Manager`.

```elixir
# Manually start Visma.Manager. This process
# is registered.
{:ok, pid} = Visma.Manager.start_link()

# Get the current token assigned to the manager.
Visma.Manager.get_token()

# Get all templates availables.
Visma.Manager.get_signing_templates()

# Get all availables templates sorted by id (Id field)
Visma.Manager.get_signing_templates_by_id()

# Get all availables templates sorted by name
# (FriendlyName field)
Visma.Manager.get_signing_templates_by_name()
```

## Low Level Usage (with `Visma.Api`)

This application can also be used as a library. Here
an example to initiate a new signature. At first,
a token is required.

```elixir
# A token is required when we do a request. If
# Visma.Manager is started, we can also call
# Visma.Manager.get_token().
{:ok, token} = Visma.Api.new()
|> Visma.Api.login(
    email: "my@email.com",
    password: "mypassword"
)
|> Visma.Api.send()
```

A signing request is required as well.

```elixir
# First, we generate a signing data-structure
signing_request = Visma.Signing.new()

# A request has mandatory parameters, like its name
# but also a reference numbeder and a valid signing
# template id (you can find it using
# Manager.Visma.get_signing_templates)
|> Visma.Signing.request(
    name: "my signing request name",
    reference_number: "12345",
    signing_template_id: "valid-signing-template-id"
)

# Next, we can configure a new sender.
|> Visma.Signing.sender(
    name: "My Sender Name",
    company_name: "My Company Name",
    email: "my@email.com",
    phone: "My Phone"
)

# Next, we can set one or many recipients. A
# valid name and CPR number are mandatory.
|> Visma.Signing.recipient(
    name: "John Doe",
    cpr: "1234567890",
    email: "john@doe.test"
)
|> Visma.Signing.recipient(
    name: "John Smith",
    cpr: "2345678901",
    email: "john@smith.com"
)

# Finally, we can now set the attachments/documents
# to send to Visma. Visma only support `application/pdf`
# mime type, so, this is the default set if not
# present.
|> Visma.Signing.document(
    name: "billing.pdf",
    data: File.read!("billing.pdf"),
    mime_type: "application/pdf"
)
```

When the request is ready, 2 methods can be
used to send the request. The first one is
using only `Visma.deliver/1` function. This
function deal with required token and other
objects.

```elixir
Visma.deliver(signing_request)
```

Or using `Visma.Api.send/1` function. This method
is more complex but it is a low level way.

```elixir
# Create a new Visma API request
Visma.Api.new()

# Set it with to deal with a new signing process
# signing_request parameter must be map()
|> Visma.Api.initiate_signing(
    token: token,
    signing_request: Visma.Signing.to_map(signing_request)
)

# Send the request
|> Visma.Api.send()
```

# References and Resources

- Visma Code Samples: https://github.com/vismaaddo/AddoSamples
- Visma REST API Documentation: https://documentation.autoinvoice.visma.com/rest-api/
- Visma API Documentation: https://support.vismaaddo.net/hc/en-us/articles/360017702120-API-documentation
- Visma Account Documentation: https://support.vismaaddo.net/hc/en-us/articles/360018618439-Test-account-for-API
- Visma Releases Notes: https://support.vismaaddo.net/hc/en-us/sections/360004890299-Release-notes
- Visma OpenAPI Documentation: https://documenter.getpostman.com/view/4950720/RWMLJkeo
