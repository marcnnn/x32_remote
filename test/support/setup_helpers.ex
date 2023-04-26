defmodule X32R.SetupHelpers do
  import ExUnit.Callbacks, only: [start_supervised: 1]

  def setup_mock_session(opts \\ []) do
    {:ok, client} = start_supervised({X32R.MockClient, opts})
    {:ok, session} = start_supervised({X32Remote.Session, client: client})
    {:ok, client, session}
  end
end
