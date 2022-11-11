defmodule BrainTrain.Score do
  use Ecto.Schema
  alias Ecto.Changeset

  schema "scores" do
    field :name, :string
    field :score, :integer
    field :game, :string
    field :user_id, :integer
  end

  @required_attrs [:name, :score, :game]

  def changeset(%__MODULE__{} = score, attrs \\ %{}) do
    score
    |> Changeset.cast(attrs, @required_attrs)
    |> Changeset.validate_required(@required_attrs)
  end
end
