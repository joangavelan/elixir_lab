defmodule WebsiteMonitor do
  def parse_yaml_config(path) do
    YamlElixir.read_from_file!(path)
  end

  def fetch_website_content(url) do
    Req.get!(url)
  end
end
