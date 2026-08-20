ExUnit.start()

defmodule NexusOrchestratorTest do
  use ExUnit.Case, async: true

  test "workspace is ready" do
    assert NexusOrchestrator.workspace_ready?()
  end
end
