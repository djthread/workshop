defmodule Lab6 do
  defmodule Room do
    defstruct [:members]
  end

  def start_link do
    Agent.start_link(fn ->
      %Room{members: %{}}
    end)
  end

  def join(pid, username) do
    from = self()
    Agent.update(pid, fn room ->
      member = %{name: username, pid: from}
      members = Map.put(room.members, username, member)
      %{room | members: members}
    end)
  end

  def leave(pid, username) do
    Agent.update(pid, fn room ->
      members = Map.delete(room.members, username)
      %{room | members: members}
    end)
  end

  def send(pid, from, to, message) do
    Agent.get(pid, fn room ->
      %{pid: pid} = Map.fetch!(room.members, to)
      send(pid, {from, message})
    end)
  end

  def broadcast(pid, from, message) do
    Agent.get(pid, fn room ->
      Enum.each(room.members, fn {_name, %{pid: pid}} ->
        send(pid, {from, message})
      end)
    end)
  end
end
