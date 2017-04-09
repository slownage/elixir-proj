defmodule Server do
    
  @doc """
    Modulul Server
    -- declaram costantele: memoria disponibila global, memoria per process
    -- la conectare verificam daca nu am depasit memoria per process 
        sau memoria disp. global
    --- msg == memorie ceruta 
  """

  @memorie_globala 10
  @memorie_proces 3

  # overhead
  @memorie_folosita 0

  def start, do: spawn(Server, :init, [])

  def init do
    Process.flag(:trap_exit, true)
    loop([])
  end

  def loop(clients) do
    receive do ## conectare
      {sender, :connect, mem} ->
        
        IO.puts(~s{[mem request = #{mem}})
        
        # verificari disponibilitate memorie
        if mem > @memorie_globala do
          mem_lipsa = mem - @memorie_globala
          IO.puts(~s{[ memorie insuficienta, +#{mem_lipsa} necesar})
          exit(0)
        end

        if mem > @memorie_proces do
          IO.puts(~s{[ memorie process depasita, limita: #{@memorie_proces}})
          exit(0)
        end

        # succes
        IO.puts(~s{ Memorie folosita = #{@memorie_folosita}})

        ## to do
        ## 1. sa se adune memoria tuturor celorlalte procese,
        #### sa se verifice daca memoria acestui nou proces nu depaseste
        
        Process.link(sender)
        loop([{mem, sender} | clients])

      ## procesul cere mai multa memorie de la server
      {sender, :req_mem, mem_req} ->
        IO.puts(~s{-- server.exs loop :req_mem --})

        mem = get_mem_from_pid(sender, clients)

        IO.puts(~s{ mem = #{mem}})
        IO.puts(~s{ mem_req = #{mem_req}})

        new_mem = mem + mem_req

        IO.puts(~s{ new_mem = #{new_mem}})

        ## to do
        ## 1. verificat daca new_mem depaseste memorie_proces
        ## 2. verificat daca noua cerere nu depaseste memoria globala
        ## 3. de actualizat {mem, sender} cu {new_mem, sender}


        loop(clients)

      # ## broadcast
      # {sender, :broadcast, msg} ->
      #   # apelam metoda la Client : loop :new_msg
      #   # broadcast({:new_msg, find(sender, clients), msg}, clients)
      #   loop(clients)

      # # exit
      # {:EXIT, pid, _} ->
      #   # broadcast({:info, find(pid, clients) <> " left the chat."}, clients)
      #   loop(clients |> Enum.filter(fn {_, rec} -> rec != pid end))
    end
  end

  # iteram prin procese si adunam memoria folosita
  def count_mem(clients) do
    Enum.each clients, fn {_, rec} -> IO.puts(~s{ rec = #{rec}}) end
  end

  # get usernames
  # def get_usernames(clients) do
  #   Enum.each clients, fn {_, pid} -> IO.puts(~s{ #{find(pid,clients)}}) end
  # end

  # defp broadcast(msg, clients) do
  #   # trimite la fiecare Client mesajul
  #   # msg = ":new_msg, find(sender, clients), msg"
  #   # pid = sender
  #   Enum.each clients, fn {_, pid} ->
  #     # IO.puts "pid = #{inspect find(pid,clients)}"
  #     send pid, msg
  #   end
  # end

  # get memorie de la pid
  defp get_mem_from_pid(sender, [{u, p} | _]) when p == sender, do: u
  defp get_mem_from_pid(sender, [_ | t]), do: get_mem_from_pid(sender, t)

end

# c("server.exs")
# c("client.exs")
# server = Server.start 
# c1 = Client.connect("Sam", server, 2)
# send c1, {:send, "Hi, anyone here?"} 
# c("server.exs"); c("client.exs"); server = Server.start; c1 = Client.connect("Sam", server, 2); send c1, {:send, "Hi, anyone here?"} 
# c("server.exs"); c("client.exs"); server = Server.start; c1 = Client.connect(2, server); send c1, {:req_mem, 1} 
