defmodule Utilities.String do
  @moduledoc """
  Extra functionality relating to strings
  """

  def as_slug(text) do
    text |> String.replace(~r/\s/, "_")
  end

  def titlecase(input) do
    input
    |> String.capitalize()
    |> String.split()
    |> Enum.map_join(" ", fn string ->
      cond do
        String.match?(string, ~r/^(and|the|with|in|is|a|an|of|or)$/) ->
          string

        String.match?(string, ~r/-/) ->
          string |> String.split("-") |> Enum.map_join("-", &String.capitalize/1)

        String.match?(string, ~r/'\w{2,}/) ->
          string |> String.split("'") |> Enum.map_join("'", &String.capitalize/1)

        true ->
          string |> String.capitalize()
      end
    end)
  end
end
