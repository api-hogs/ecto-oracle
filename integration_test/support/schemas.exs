defmodule EctoOracleAdapter.Integration.Schema do
  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      type =
        Application.get_env(:ecto, :primary_key_type) ||
        raise ":primary_key_type not set in :ecto application"
      @primary_key {:id, type, autogenerate: true}
      @foreign_key_type type
    end
  end
end

defmodule EctoOracleAdapter.Integration.Post do
  @moduledoc """
  This module is used to test:

    * Overall functionality
    * Overall types
    * Non-null timestamps
    * Relationships
    * Dependent callbacks

  """
  use EctoOracleAdapter.Integration.Schema
  import Ecto.Changeset

  schema "posts" do
    field :counter, :id # Same as integer
    field :title, :string
    field :text, :binary
    field :temp, :string, default: "temp", virtual: true
    field :public, :boolean, default: true
    field :cost, :decimal
    field :visits, :integer
    field :intensity, :float
    field :bid, :binary_id
    field :uuid, Ecto.UUID, autogenerate: true
    field :meta, :map
    field :posted, Ecto.Date
    belongs_to :author, EctoOracleAdapter.Integration.User
    many_to_many :users, EctoOracleAdapter.Integration.User,
      join_through: "posts_users", on_delete: :delete_all, on_replace: :delete
    timestamps
  end

  def changeset(model, params) do
    cast(model, params, [], ~w(counter title text temp public cost visits
                               intensity bid uuid meta posted))
  end
end

defmodule EctoOracleAdapter.Integration.PostUsecTimestamps do
  @moduledoc """
  This module is used to test:

    * Usec timestamps

  """
  use EctoOracleAdapter.Integration.Schema

  schema "posts" do
    field :title, :string
    timestamps usec: true
  end
end

defmodule EctoOracleAdapter.Integration.UserPost do
  @moduledoc """
  This module is used to test:

    * Many to many associations join_through with schema

  """
  use EctoOracleAdapter.Integration.Schema

  schema "users_posts" do
    belongs_to :user, EctoOracleAdapter.Integration.User
    belongs_to :post, EctoOracleAdapter.Integration.Post
    timestamps
  end
end

defmodule EctoOracleAdapter.Integration.User do
  @moduledoc """
  This module is used to test:

    * Timestamps
    * Relationships
    * Dependent callbacks

  """
  use EctoOracleAdapter.Integration.Schema

  schema "users" do
    field :name, :string
    has_many :posts, EctoOracleAdapter.Integration.Post, foreign_key: :author_id, on_delete: :nothing, on_replace: :delete
    many_to_many :schema_posts, EctoOracleAdapter.Integration.Post, join_through: EctoOracleAdapter.Integration.UserPost
    timestamps
  end
end
