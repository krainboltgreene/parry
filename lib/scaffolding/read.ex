defmodule Scaffolding.Read do
  @moduledoc false
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__([schema, plural, singular])
           when is_atom(singular) do
    quote location: :keep do
      import Ecto.Query

      @doc """
      Counts the number of `#{unquote(schema)}` records in the database.
      """
      @spec unquote(:"count_#{plural}")() :: integer()
      def unquote(:"count_#{plural}")() do
        Core.Repo.aggregate(unquote(schema), :count, :id)
      end

      @doc """
      Randomly selects a unique `#{unquote(schema)}` record where the primary key arent the ones provided
      """
      @spec unquote(:"random_unique_#{singular}")(excluding: list()) :: unquote(schema).t() | nil
      def unquote(:"random_unique_#{singular}")(excluding: ids) when is_list(ids) do
        (record in unquote(schema))
        |> from(limit: 1, order_by: fragment("random()"), where: record.id not in ^ids)
        |> Core.Repo.one()
      end

      @doc """
      Randomly selects a `#{unquote(schema)}` record based on a set of conditions
      """
      @spec unquote(:"random_#{singular}")(Keyword.t()) :: unquote(schema).t() | nil
      def unquote(:"random_#{singular}")(where: where) do
        unquote(schema)
        |> from(limit: 1, order_by: fragment("random()"), where: ^where)
        |> Core.Repo.one()
      end

      @doc """
      Randomly selects a `#{unquote(schema)}` record
      """
      @spec unquote(:"random_#{singular}")() :: unquote(schema).t() | nil
      def unquote(:"random_#{singular}")(),
        do: from(unquote(schema), limit: 1, order_by: fragment("random()")) |> Core.Repo.one()

      @doc """
      Returns all `#{unquote(schema)}` records sorted by the given order, see Ecto's `Ecto.Query.API.order_by/1` for more details
      """
      @spec unquote(:"list_#{plural}")(Keyword.t()) :: list(unquote(schema).t())
      def unquote(:"list_#{plural}")(order),
        do: from(unquote(schema), order_by: ^order) |> Core.Repo.all()

      @doc """
      Returns all `#{unquote(schema)}` records, unsorted
      """
      @spec unquote(:"list_#{plural}")() :: list(unquote(schema).t())
      def unquote(:"list_#{plural}")(), do: unquote(schema) |> Core.Repo.all()

      @doc """
      Returns a singular `#{unquote(schema)}` based on a query, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}!")((unquote(schema).t() -> Ecto.Query.t())) ::
              unquote(schema).t()
      def unquote(:"get_#{singular}!")(function) when is_function(function, 1),
        do: function.(unquote(schema)) |> Core.Repo.one!()

      @doc """
      Returns a singular `#{unquote(schema)}` based on a query and if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}")((unquote(schema).t() -> Ecto.Query.t())) ::
              unquote(schema).t() | nil
      def unquote(:"get_#{singular}")(function) when is_function(function, 1),
        do: function.(unquote(schema)) |> Core.Repo.one()

      @doc """
      Returns a singular `#{unquote(schema)}` based on the primary key, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}!")(String.t()) :: unquote(schema).t()
      def unquote(:"get_#{singular}!")(id) when is_binary(id),
        do: unquote(schema) |> Core.Repo.get!(id)

      @doc """
      Returns a singular `#{unquote(schema)}` based on the primary key and if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}")(String.t()) :: unquote(schema).t() | nil
      def unquote(:"get_#{singular}")(id) when is_binary(id),
        do: unquote(schema) |> Core.Repo.get(id)
    end
  end
end
