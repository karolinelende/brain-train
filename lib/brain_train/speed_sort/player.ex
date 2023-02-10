defmodule BrainTrain.SpeedSort.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  embedded_schema do
    field :name, :string
    field :score, :integer
    field :clicks, :integer
    field :round, :integer
    field :round_start_time, :utc_datetime_usec
    field :numbers, {:array, :integer}
    field :previous_round_result, :string
  end

  @type t :: %Player{
          name: nil | String.t(),
          score: :integer,
          clicks: :integer,
          round: :integer,
          round_start_time: nil | :utc_datetime_usec,
          numbers: nil | list(:integer),
          previous_round_result: nil | String.t()
        }

  @fields [:name, :score, :round, :clicks, :previous_round_result]

  def insert_changeset(attrs) do
    changeset(%Player{}, attrs)
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, @fields)
    |> validate_required([:name])
    |> generate_id()
  end

  defp generate_id(changeset) do
    case get_field(changeset, :id) do
      nil ->
        put_change(changeset, :id, Ecto.UUID.generate())

      _value ->
        changeset
    end
  end

  def create(params) do
    params
    |> Map.merge(%{score: 0, round: 0, clicks: 0, previous_round_result: nil})
    |> insert_changeset()
    |> apply_action(:insert)
  end
end
