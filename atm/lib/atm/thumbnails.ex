defmodule Atm.Thumbnails do
  alias HubContext.Schema.Order

  def fetch_for(%Order{link: link, thumbnail_url: url}) do
    url = resize_thumbnail_url(url)
    name = "#{Order.asin(link)}.jpg"

    path =
      Application.get_env(:atm, :thumbnail_dir, "/tmp/thumbnails")
      |> Path.join(name)

    # TODO: Clean these up occasionally
    # Maybe download async as a task
    unless File.exists?(path) do
      File.mkdir_p(Path.dirname(path))
      Download.from(url, path: path)
    end

    hash = Scenic.Cache.Support.Hash.file!(path, :sha)

    Scenic.Cache.Static.Texture.load(path, hash)

    hash
  end

  defp resize_thumbnail_url(url, new_size \\ "200") do
    [size | _] = Regex.run(~r/\._.*_\.(jpg|jpeg)$/, url, capture: :first)
    new = String.replace(size, ~r/\d+/, new_size)
    String.replace(url, size, new)
  rescue
    _e -> url
  end
end
