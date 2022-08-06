defmodule Mix.SlackApiDocs.Helpers do
  @doc ~S"""
  Partitions the given list into a fixed amount of chunks.
  The size of every chunk depends on the overall size of the given list.
  The size of the last chunk can vary based on the left over amount.

  ## Usage

      iex> Mix.SlackApiDocs.Helpers.partition_list([1, 2, 3, 4, 5, 6], 3)
      [[1, 2], [3, 4], [5, 6]]

      iex> Mix.SlackApiDocs.Helpers.partition_list([1, 2, 3, 4, 5, 6, 7], 3)
      [[1, 2, 3], [4, 5, 6], [7]]
  """
  @spec partition_list(maybe_improper_list, pos_integer) :: [list]
  def partition_list(list, chunks_amount)
      when is_list(list) and is_integer(chunks_amount) and chunks_amount > 0 do
    pool_size =
      (Enum.count(list) / chunks_amount)
      |> Float.ceil()
      |> Kernel.trunc()

    Enum.chunk_every(list, pool_size)
  end
end
