defmodule SpTest do
  @moduledoc """

  """
  use ExUnit.Case

  describe "ignore BOFREEPC2 from stream" do
    test "Ignore BOFREEPC1|BOFREEPC2 " do
      expected_output = %{
        msisdn: "2211402406",
        modalidad: "AHORRO",
        plan: "KE",
        estado: "V",
        bono1: "BOFREEPC1",
        bono2: "BOFREEPC2"
      }

      assert expected_output == Sp.parse("2211402406|AHORRO|KE|V|BOFREEPC1|BOFREEPC2")
    end

    test "from map to record" do
      input = %{
        msisdn: "2211402406",
        modalidad: "AHORRO",
        plan: "KE",
        estado: "V",
        bono1: "BOFREEPC1",
        bono2: "BOFREEPC2"
      }

      assert "2211402406|AHORRO|KE|V|BOFREEPC1|BOFREEPC2" == Sp.to_str(input)
    end

    test "parse_file without bonus" do
      path = "priv/data/example.csv"
      assert [
        %{
          bono1: "",
          bono2: "",
          estado: "A",
          modalidad: "POSPAGO",
          msisdn: "8113937618",
          plan: "FX"
        }] == path
            |> Sp.read_file()
            |> Sp.filter_without_bonus()
            |> Sp.to_list_of_maps()
    end

    test "parse_file without one bonus" do
      path = "priv/data/example.csv"
      assert [
        %{
          bono1: "BOFREEPC1",
          bono2: "",
          estado: "T",
          modalidad: "AHORRO",
          msisdn: "6141505867",
          plan: "KE"
        }
      ] == path
            |> Sp.read_file()
            |> Sp.filter_with_one_bonus()
            |> Sp.to_list_of_maps()
    end

    test "parse_file without two bonus" do
      path = "priv/data/example.csv"
      assert [
        [
          %{bono1: "BOFREEPC1", bono2: "BOFREEPC2", estado: "V", modalidad: "AHORRO", msisdn: "8112071811", plan: "KE"},
          %{bono1: "BOFREEPC1", bono2: "BOFREEPC2", estado: "A", modalidad: "POSPAGO", msisdn: "8112073392", plan: "OY"},
          %{bono1: "BOFREEPC1", bono2: "BOFREEPC2", estado: "V", modalidad: "AHORRO", msisdn: "8112079632", plan: "OB"}
        ],
        [
          %{bono1: "BOFREEPC1", bono2: "BOFREEPC2", estado: "W", modalidad: "AHORRO", msisdn: "8112080201", plan: "KE"},
          %{bono1: "BOFREEPC1", bono2: "BOFREEPC2", estado: "V", modalidad: "AHORRO", msisdn: "8112080250", plan: "KE"}
        ]
      ] == path
            |> Sp.read_file()
            |> Sp.filter_with_two_bonus()
            |> Sp.to_chunk(3)
            |> Sp.to_list_of_maps()

    end

    test "to multiple files" do
      path = "priv/data/example.csv"
      assert :ok = path
            |> Sp.read_file()
            |> Sp.filter_with_two_bonus()
            |> Sp.to_files("output.txt", 3)


      assert true = File.exists?("priv/data/00_output.txt")
      assert true = File.exists?("priv/data/01_output.txt")
    end
  end
end
