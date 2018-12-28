defmodule Etoile.Bot do
  @bot :simple_bot
  def bot(), do: @bot

  use ExGram.Bot, name: @bot
  require Logger

  command("echo")
  middleware(ExGram.Middleware.IgnoreUsername)

  def handle({:text, text, _}, cnt) do
    IO.puts "Bot respondiendo..."
    IO.inspect text
    cnt |> answer(" Aprendiendo IoT Primeros Pasos Demo:: Hola, ya te atiendo con Elixir 🤖")
  end

  def handle({:command, :echo, %{text: t}}, cnt) do
    cnt |> answer(t)
  end

end
