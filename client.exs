defmodule Client do

  def connect(mem, server) do
    # spwn client, apeleaza def init(un,server) de mai jos
    spawn(Client, :init, [mem, server])
  end

  def init(mem, server) do
    # trimite la server cerinta de :connect
    send server, {self(), :connect, mem}

    # 
    loop(mem, server)
  end

  def loop(mem, server) do
    receive do
      {:info, msg} ->
        IO.puts(~s{[#{inspect self()}'s client] - #{msg}})
        loop(mem, server)
      {:new_msg, from, msg} ->
        IO.puts(~s{[#{inspect self()}'s client] - #{from}: #{msg}})
        loop(mem, server)
      {:send, msg} ->
        send server, {self(), :broadcast, msg}
        loop(mem, server)
      {:req_mem, mem_req} ->
        IO.puts(~s{ :req_mem #{inspect self()} })
        send server, {self(), :req_mem, mem_req}
        loop(mem, server)
      :disconnect ->
        exit(0)
    end
  end
end 