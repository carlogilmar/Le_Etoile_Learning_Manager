defmodule Etoile.TaskManager do

  alias Etoile.Calendar
  alias Etoile.Parser

  @todo "TODO"
  @doing "DOING"
  @done "DONE"

  # Status: TODO, DOING, DONE
  def filter_by_status( tasks ) do
    todos = get_status( tasks, @todo )
    doing = get_status( tasks, @doing )
    done = get_status( tasks, @done )
    { todos, doing, done }
  end

  def get_wip( tasks )do
    get_status( tasks, @doing )
  end

  def get_status( tasks, status) do
    Enum.filter( tasks, fn task -> task["status"] == status end )
  end

  def create_task( title ) do
    { day, _, year, month } = Calendar.get_current_day
    id = Parser.get_uuid()
    current_user = get_current_user()
    %{ id: id, title: title, status: @todo, day: day, month: month, year: year, user: current_user }
  end

  def get_current_user() do
    { user, _} = System.cmd("whoami", [])
    Parser.parse_command( user )
  end

  def find_task( tasks, task_id, status ) do
    Enum.filter( tasks, fn task -> task["id"] == task_id end ) |> prepare_for_update( status )
  end

  def prepare_for_update( [], _ ), do: Parser.print_with_color " \n Invalid Task ID", :color198
  def prepare_for_update( [ task ], status ) do
    firebase_uuid = task["firebase_uuid"]
    task_updated = get_updated_task( task, status )
    { firebase_uuid, task_updated }
  end

  def get_updated_task( task, "DOING" ) do
    Map.put( task, "status", @doing)
      |> Map.delete("firebase_uuid")
      |> Map.put("start_time", :os.system_time(:millisecond) )
  end

  def get_updated_task( task, "DONE" ) do
    Map.put( task, "status", @done)
      |> Map.delete("firebase_uuid")
      |> Map.put("end_time", :os.system_time(:millisecond) )
  end

  def get_updated_task( task, _ ) do
    Map.put( task, "status", @todo)
      |> Map.delete("firebase_uuid")
      |> Map.delete("start_time")
      |> Map.delete("end_time")
  end

  def add_done_task( title, duration) do
    { day, _, year, month } = Calendar.get_current_day
    id = Parser.get_uuid()
    current_user = get_current_user()
    minutes = (duration * 60) * 1000
    end_time = :os.system_time(:millisecond)
    start_time = end_time - minutes
    %{ id: id, title: title, status: @done, day: day, month: month, year: year, user: current_user, start_time: start_time, end_time: end_time}
  end

end
