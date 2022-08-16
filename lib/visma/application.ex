defmodule Visma.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Visma.Manager, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Visma.Supervisor)
  end
end
