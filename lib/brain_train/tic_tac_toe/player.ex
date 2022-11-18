defmodule BrainTrain.TicTacToe.Player do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  embedded_schema do
    field :name, :string
    field :letter, :string
  end

  @type t :: %Player{
          name: nil | String.t(),
          letter: nil | String.t()
        }

  def insert_changeset(attrs) do
    changeset(%Player{}, attrs)
  end

  def changeset(player, attrs) do
    player
    |> cast(attrs, [:name, :letter])
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
    |> insert_changeset()
    |> apply_action(:insert)
  end
end
