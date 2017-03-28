defmodule ClientsManager.TableSpec do
  use ESpec, async: true

  let :name, do: :test
  let :table, do: described_module().create(name(), [:private])

  describe "create/1" do
    it "creates table with passed name" do
      expect fn -> :ets.delete(table()) end
      |> to_not(raise_exception ArgumentError)
    end
  end

  describe "insert/2" do
    let :data, do: "data"

    it "inserts data and returns id" do
      id = described_module().insert(table(), {data()})
      expect :ets.lookup(table(), id) |> to(eq [{id, data()}])
    end

    it "increment id every time" do
      id1 = described_module().insert(table(), {data()})
      id2 = described_module().insert(table(), {data()})
      expect id1 |> to(eq id2 - 1)
    end
  end

  describe "find/2" do
    let :data, do: "data"

    context "when id exists" do
      let :id, do: described_module().insert(table(), {data()})

      it "returns :ok with data" do
        expect described_module().find(table(), id())
        |> to(eq {:ok, {data()}})
      end
    end

    context "when id does not exist" do
      let :id, do: 987654321

      it "returns :error" do
        expect described_module().find(table(), id())
        |> to(eq :error)
      end
    end
  end

  describe "update/3" do
    let :data, do: "data"
    let :new_data, do: "new_data"

    context "when id exists" do
      let :id, do: described_module().insert(table(), {data()})

      it "updates row" do
        described_module().update(table(), id(), {new_data()})
        expect :ets.lookup(table(), id()) |> to(eq [{id(), new_data()}])
      end

      it "returns :ok with new_data" do
        expect described_module().update(table(), id(), {new_data()})
        |> to(eq {:ok, {new_data()}})
      end
    end

    context "when id does not exist" do
      let :id, do: 987654321

      it "does not update row" do
        described_module().update(table(), id(), {new_data()})
        expect :ets.lookup(table(), id()) |> to(eq [])
      end

      it "returns :error" do
        expect described_module().update(table(), id(), {new_data()})
        |> to(eq :error)
      end
    end
  end

  describe "delete/2" do
    let :data, do: "data"

    context "when id exists" do
      let :id, do: described_module().insert(table(), {data()})

      it "deletes row" do
        described_module().delete(table(), id())
        expect :ets.lookup(table(), id()) |> to(eq [])
      end

      it "returns :ok with old data" do
        expect described_module().delete(table(), id())
        |> to(eq {:ok, {data()}})
      end
    end

    context "when id does not exist" do
      let :id, do: 987654321

      it "returns :error" do
        expect described_module().delete(table(), id())
        |> to(eq :error)
      end
    end
  end

  describe "destroy/1" do
    it "destroys table" do
      described_module().destroy(table())
      expect fn -> :ets.delete(table()) end
      |> to(raise_exception ArgumentError)
    end
  end

  describe "each/2" do
    let :data1, do: "data1"
    let! :id1, do: described_module().insert(table(), {data1()})
    let :data2, do: "data2"
    let! :id2, do: described_module().insert(table(), {data2()})
    let :data3, do: "data3"
    let! :id3, do: described_module().insert(table(), {data3()})

    it "iterates over table" do
      {:ok, agent} = Agent.start_link fn -> [] end
      described_module().each(
        table(),
        fn(id, data) ->
          Agent.update(agent, fn list -> [{id, data} | list] end)
        end
      )
      expect Agent.get(agent, fn list -> list end) |> to(eq(
        [
          {id3(), {data3()}},
          {id2(), {data2()}},
          {id1(), {data1()}}
        ]
      ))
      Agent.stop(agent)
    end
  end

  describe "map/2" do
    let :data1, do: "data1"
    let! :id1, do: described_module().insert(table(), {data1()})
    let :data2, do: "data2"
    let! :id2, do: described_module().insert(table(), {data2()})
    let :data3, do: "data3"
    let! :id3, do: described_module().insert(table(), {data3()})

    it "map over table" do
      list = described_module().map(
        table(),
        fn(id, {data}) -> {id, data} end
      )
      expect list |> to(eq(
        [
          {id1(), data1()},
          {id2(), data2()},
          {id3(), data3()},
        ]
      ))
    end
  end
end
