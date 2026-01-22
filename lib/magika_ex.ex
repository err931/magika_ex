defmodule MagikaEx do
  @moduledoc """
  MagikaEx is an Elixir wrapper for Google's Magika, a deep-learning-based content-type detection tool.

  This module uses a `GenServer` to manage a native Magika session resource, ensuring safe
  and efficient access to the underlying Rust-based identification engine.
  """

  use GenServer
  alias MagikaEx.Native

  @name __MODULE__

  @doc """
  Starts the `MagikaEx` GenServer.

  This initializes the native Magika session required for content identification.
  """
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, @name)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Identifies the content type of the given binary data.

  Returns a `%MagikaEx.Result{}` struct containing details such as the label, score, and group.
  """
  def identify_bytes(data) when is_binary(data) do
    resource = GenServer.call(@name, :get_resource)
    Native.identify_bytes(resource, data)
  end

  @doc """
  Identifies the content type of a file at the specified path.

  Returns `{:ok, %MagikaEx.Result{}}` on success or `{:error, reason}` if the file cannot be read.
  """
  def identify_path(path) do
    with {:ok, binary} <- File.read(path) do
      {:ok, identify_bytes(binary)}
    end
  end

  @impl true
  def init(:ok) do
    case Native.new() do
      resource when is_reference(resource) ->
        {:ok, resource}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_call(:get_resource, _from, resource) do
    {:reply, resource, resource}
  end
end

defmodule MagikaEx.Result do
  @moduledoc """
  A struct representing the identification result from Magika.

  Fields:
  * `:label` - The detected content type label (e.g., "python").
  * `:score` - The confidence score for the prediction.
  * `:mime_type` - The associated MIME type (e.g., "text/x-python").
  * `:group` - The high-level category of the content (e.g., "code", "image").
  * `:description` - A human-readable description of the detected type.
  * `:is_text` - Boolean indicating whether the content is text-based.
  """
  defstruct [:label, :score, :mime_type, :group, :description, :is_text]
end
