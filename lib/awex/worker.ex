defmodule Awex.Worker do
  use Task, restart: :transient

  alias Awex.AwesomeLibs.{Section, Lib}


  def start_link(arg) do
    IO.puts "Starting..."
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(_arg) do
    :timer.sleep(3000)
    number = Enum.random(0..3)

    if number == 1 || number == 2 do
      IO.puts("CRASH")
      raise inspect(number)
    end

    IO.puts(number)

    number
  end
end
