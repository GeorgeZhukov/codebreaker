require "spec_helper"

module Codebreaker
  describe Player do
    subject { Player.new("Username", 3, 40) }

    describe "#initialize" do

      it "accepts three arguments" do
        expect { subject }.not_to raise_exception
      end

      it "sets username" do
        expect(subject.instance_variable_get(:@username)).to eq "Username"
      end

      it "sets attempts" do
        expect(subject.instance_variable_get(:@attempts)).to eq 3
      end

      it "sets complete" do
        expect(subject.instance_variable_get(:@complete)).to eq 40
      end
    end

    describe "#to_s" do
      it "returns player string in correct format" do
        expect(subject.to_s).to eq "Username, Attempts: 3, Complete: 40%"
      end
    end

    describe "username" do
      it "accessible" do
        expect(subject.username).to eq "Username"
      end

    end

    describe "attempts" do
      it "accessible" do
        expect(subject.attempts).to eq 3
      end
    end

    describe "complete" do
      it "accessible" do
        expect(subject.complete).to eq 40
      end
    end

    describe ".load_collection" do

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:read).and_return(:raw_data)
        allow(Marshal).to receive(:load).and_return([subject])
      end

      it "returns an array" do
        expect(Player.load_collection.class).to be Array
      end

      it "returns an array of players" do
        expect(Player.load_collection[0].class).to be Player
      end

      it "uses File.read" do
        expect(File).to receive(:read).with("players.bin").once
        Player.load_collection
      end

      it "uses Marshal.load" do
        expect(Marshal).to receive(:load).once
        Player.load_collection
      end

      it "returns an empty array if file not exists" do
        allow(File).to receive(:exist?).and_return(false)
        expect(Player.load_collection).to be_empty
      end

      it "returns an array from Marshal.load" do
        expect(Player.load_collection).to match_array [subject]
      end

      it "returns sorted collection by complete" do
        michael = Player.new("Michael", 10, 75)
        george = Player.new("George", 3, 100)
        niko = Player.new("Niko", 10, 0)

        players = []
        players << michael
        players << george
        players << niko

        allow(Marshal).to receive(:load).once.and_return(players)
        result = Player.load_collection
        expect(result).to eq [george, michael, niko]
      end
    end

    describe ".add_to_collection" do

      before do
        allow(File).to receive(:exist?).and_return(true)
        allow(Marshal).to receive(:dump)
        allow(File).to receive(:write)
        allow(Player).to receive(:load_collection).and_return([subject])
      end

      it "accepts one argument" do
        expect { Player.add_to_collection subject }.not_to raise_exception
      end

      it "calls .load_collection" do
        expect(Player).to receive(:load_collection).once
        Player.add_to_collection subject
      end

      it "uses Marshal.dump" do
        expect(Marshal).to receive(:dump).once
        Player.add_to_collection subject
      end

      it "uses File.write" do
        allow(Marshal).to receive(:dump).once.and_return(:raw_data)
        expect(File).to receive(:write).with("players.bin", :raw_data).once
        Player.add_to_collection subject
      end
    end
  end
end