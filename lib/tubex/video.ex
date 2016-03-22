defmodule Tubex.Video do

  defstruct title: nil, etag: nil, video_id: nil, channel_id: nil, channel_title: nil, description: nil, published_at: nil, thumbnails: []

  def query(string) do
    Tubex.API.get(Tubex.endpoint <> "/video")
  end

  @doc """
  fetch contents details
  """
  def detail(video_id) do
    opts = [key: Tubex.api_key, id: video_id, part: "contentDetails"]
    case Tubex.API.get(Tubex.endpoint <> "/videos", opts) do
      {:ok, response} ->
        response
      err -> err
    end
  end

  @doc """
  Search from youtube via query.
  """
  def search_by_query(query, opts \\ []) do
    defaults = [key: Tubex.api_key, part: "snippet", maxResults: 20, type: "video", q: query]
    opts = Keyword.merge(defaults, opts)

    case Tubex.API.get(Tubex.endpoint <> "/search", opts) do
      {:ok, response} ->
        {:ok, Enum.map(response["items"], &parse!/1)}
      err -> err
    end
  end

  def related_with_video(video_id, opts \\ []) do
    defaults = [key: Tubex.api_key, part: "snippet", maxResults: 20, type: "video", relatedToVideoId: video_id]
    opts = Keyword.merge(defaults, opts)
    case Tubex.API.get(Tubex.endpoint <> "/search", opts) do
      {:ok, response} ->
        Enum.map(response["items"], &parse!/1)
      err -> err
    end
  end

  defp to_key_atom({k, v}) do
    {String.to_atom(k), v}
  end

  defp parse!(body) do
    case parse(body) do
      {:ok, video} -> video
      {:error, body} -> raise "Parse error occured! #{body}"
    end
  end

  defp parse(%{"snippet" => snippet, "id" => %{"videoId" => video_id}}) do
    {:ok,
      %Tubex.Video{
        etag: snippet["etag"],
        title: snippet["title"],
        thumbnails: Enum.map(snippet["thumbnails"], &to_key_atom/1),
        published_at: snippet["publishedAt"],
        channel_title: snippet["channelTitle"],
        channel_id: snippet["channelId"],
        description: snippet["description"],
        video_id: video_id
      }
    }
  end

  defp parse(body) do
    {:error, body}
  end
end