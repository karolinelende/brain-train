defmodule BrainTrain.Repo.Migrations.AddScoresTable do
  use Ecto.Migration

  def change do
    create table(:scores) do
      add :name, :string
      add :score, :integer
      add :game, :string
      add :user_id, :integer
    end
  end
end
