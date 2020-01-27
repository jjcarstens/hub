defmodule Genie.AccessCodes do
  use Agent

  @jonjon "2486"
  @stephanie "0503"

  defmodule Meta do
    defstruct added_at: nil, allowed_uses: 2, expires_in: 900, use_count: 0
  end

  def start_link(_ \\ []) do
    # Parents master codes
    master_codes = %{
      @jonjon => %Meta{allowed_uses: :infinity},
      @stephanie => %Meta{allowed_uses: :infinity}
    }

    Agent.start_link(fn -> master_codes end, name: __MODULE__)
  end

  def create_temp(opts \\ []) do
    code =
      :io_lib.format("~4..0B", [:rand.uniform(10_000) - 1])
      |> to_string()

    # ignore the master codes
    if code in [@jonjon, @stephanie] do
      create_temp(opts)
    else
      new(code, opts)
      code
    end
  end

  def delete(code) do
    Agent.update(__MODULE__, &Map.delete(&1, code))
  end

  def new(code, opts \\ []) do
    meta = struct(Meta, Keyword.put(opts, :added_at, now()))

    Agent.update(__MODULE__, &Map.put(&1, code, meta))
  end

  def valid?(code) do
    with %Meta{} = m <- Agent.get(__MODULE__, &Map.get(&1, code, false)),
         true <- not is_expired?(code, m),
         true <- m.allowed_uses == :infinity || m.use_count < m.allowed_uses do
      mark_use(code, m)
      true
    else
      e -> e
    end
  end

  defp is_expired?(_code, %{allowed_uses: :infinity}), do: false

  defp is_expired?(code, %{added_at: added, expires_in: expiration}) do
    expired? = now() - added > expiration

    if expired?, do: delete(code)

    expired?
  end

  defp mark_use(code, %{allowed_uses: a, use_count: c}) when a == c + 1 do
    delete(code)
  end

  defp mark_use(code, %{use_count: c} = meta) do
    meta = %{meta | use_count: c + 1}
    Agent.update(__MODULE__, &Map.put(&1, code, meta))
  end

  defp now() do
    System.monotonic_time(:second)
  end
end
