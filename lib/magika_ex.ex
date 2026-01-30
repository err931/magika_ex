defmodule MagikaEx do
  @moduledoc """
  Provides the main interface for using Magika to identify the content type of
  files or binary data.

  This module offers functions that wrap the Magika engine and allow you to
  classify file contents in an efficient and convenient way.
  """

  use GenServer

  alias MagikaEx.Native

  @type option :: GenServer.option()

  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(opts \\ []) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Identify the data type of raw bytes.
  """
  @spec identify_bytes(binary()) :: {:ok, MagikaEx.Result.t()} | {:error, term}
  def identify_bytes(data) when is_binary(data) do
    resource = GenServer.call(__MODULE__, :get_resource)
    {:ok, Native.identify_bytes(resource, data)}
  end

  @doc """
  Identify the data type of a file given its path.
  """
  @spec identify_path(String.t()) :: {:ok, MagikaEx.Result.t()} | {:error, term}
  def identify_path(path) when is_binary(path) do
    with {:ok, binary} <- File.read(path) do
      identify_bytes(binary)
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
  File type information with inference scoring.
  """

  @typedoc "A struct representing the identification result from Magika."
  @type t :: %__MODULE__{
          label: String.t(),
          mime_type: String.t(),
          group: String.t(),
          description: String.t(),
          score: float(),
          is_text: boolean()
        }

  @doc """
  File type information.

  ## Fields
  * `:label` - The unique label identifying this file type.
  * `:mime_type` - The MIME type of the file type.
  * `:group` - The group of the file type.
  * `:description` - The description of the file type.
  * `:score` - The inference score between 0 and 1.
  * `:is_text` - Whether the file type is text.
  """
  @enforce_keys [:label, :mime_type, :group, :description, :score, :is_text]
  defstruct [:label, :mime_type, :group, :description, :score, :is_text]
end
