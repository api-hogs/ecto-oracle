defmodule EctoOracleAdapter.Integration.Migration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :text
      add :custom_id, :uuid
      timestamps
    end

    create table(:posts) do
      add :title, :string, size: 100
      add :counter, :integer
      add :text, :binary
      add :bid, :binary_id
      add :uuid, :uuid
      add :meta, :map
      add :public, :boolean
      add :cost, :decimal, precision: 2, scale: 1
      add :visits, :integer
      add :intensity, :float
      add :author_id, :integer
      add :posted, :date
      timestamps null: true
    end

    create table(:posts_users, primary_key: false) do
      add :post_id, references(:posts)
      add :user_id, references(:users)
    end

    create table(:users_posts) do
      add :post_id, references(:posts)
      add :user_id, references(:users)
      timestamps
    end

    create table(:transactions) do
      add :text, :string
    end
  end
end
