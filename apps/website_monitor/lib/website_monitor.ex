defmodule WebsiteMonitor do
  def parse_yaml_config(path) do
    YamlElixir.read_from_file!(path)
  end
end
