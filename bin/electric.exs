{opts, [outpath], _} = OptionParser.parse(System.argv(), strict: [in: :string])
source = File.read!(opts[:in])

IO.puts(
  :stderr,
  IO.ANSI.format(["Writing pre-processed sql file to ", :green, "#{outpath}", :reset, "\n\n"])
)

migration =
  Regex.scan(~r/^CREATE OR REPLACE FUNCTION ([a-z_]+\()/m, source)
  |> Enum.map(fn [_, f] -> f end)
  |> Enum.uniq()
  |> Enum.reduce(source, fn func, source ->
    String.replace(
      source,
      func,
      "@schemaname@.#{func}",
      global: true
    )
  end)

IO.puts(migration)
