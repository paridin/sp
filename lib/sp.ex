defmodule Sp do
  @moduledoc """
  Sp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def read_file(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&parse/1)
  end

  def parse(record) when is_bitstring(record) do
    [msisdn, modalidad, plan, estado, bono1, bono2] = String.split(record,"|")
    %{
      msisdn: msisdn,
      modalidad: modalidad,
      plan: plan,
      estado: estado,
      bono1: bono1,
      bono2: bono2
    }
  end

  def filter_without_bonus(stream) do
    stream
    |> Stream.filter(fn record -> record.bono1 == "" && record.bono2 == "" end)
  end

  def filter_with_one_bonus(stream, bono_1 \\ "BOFREEPC1") do
    stream
    |> Stream.filter(fn record -> record.bono1 == bono_1 && record.bono2 == "" end)
  end

  def filter_with_two_bonus(stream, bono_1 \\ "BOFREEPC1", bono_2 \\ "BOFREEPC2") do
    stream
    |> Stream.filter(fn record -> record.bono1 == bono_1 && record.bono2 == bono_2 end)
  end

  def to_str(i) when is_map(i) do
    [i.msisdn, i.modalidad, i.plan, i.estado, i.bono1, i.bono2]
    |> Enum.join("|")
  end

  def to_list_of_maps(stream) do
    stream
    |> Enum.to_list()
  end

  def to_chunk(stream, n) do
    stream
    |> Stream.chunk_every(n)
  end

  def to_files(stream, filename, chunk_by) do
    stream
    |> to_chunk(chunk_by)
    |> Stream.with_index()
    |> Stream.map(fn chunked -> save_to_file(chunked, filename) end)
    |> Stream.run()
  end

  defp save_to_file({chunk, index}, filename) do
    idx = case index < 10 do
      true -> "0#{index}"
      false -> "#{index}"
    end

    chunk
    |> Stream.map(&"#{to_str(&1)}\n")
    |> Stream.into(File.stream!("priv/data/#{idx}_#{filename}"))
    |> Stream.run()
  end

# API
  def report_without_bonus(source, output_name, chunk_by) do
    source
      |> read_file()
      |> filter_without_bonus()
      |> to_files(output_name, chunk_by)
  end

  def report_one_bonus(source, output_name, chunk_by) do
    source
      |> read_file()
      |> filter_with_one_bonus()
      |> to_files(output_name, chunk_by)
  end

  def report_two_bonus(source, output_name, chunk_by) do
    source
      |> read_file()
      |> filter_with_two_bonus()
      |> to_files(output_name, chunk_by)
  end
end
