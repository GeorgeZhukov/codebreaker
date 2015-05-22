require 'spec_helper'

module Codebreaker
  describe Game do

    describe "#initialize" do

      it "saves secret code" do
        expect(subject.instance_variable_defined?(:@secret_code)).to be true
      end

      it "saves secret code with 4 items" do
        expect(subject.instance_variable_get(:@secret_code).size).to eq 4
      end

      it "saves secret code with numbers from 1 to 6" do
        expect(subject.instance_variable_get(:@secret_code).join).to match /^[1-6]{4}$/
      end

      it "sets has_hint to true" do
        expect(subject.instance_variable_get(:@has_hint)).to be true
      end

      it "sets available_attempts to 10" do
        expect(subject.instance_variable_get(:@available_attempts)).to eq 10
      end

      it "uses random numbers to generate a secret code" do
        allow_any_instance_of(Game).to receive(:rand).and_return(1,2,3,4)
        game = Game.new
        expect(game.instance_variable_get(:@secret_code)).to eq [1,2,3,4]
      end
    end

    describe "#cheat" do
      it "shows a correct secret code" do
        subject.instance_variable_set(:@secret_code, [1,2,3,4])
        expect(subject.cheat).to eq "1234"
      end
    end

    describe "available_attempts" do
      it "has getter" do
        expect(subject.available_attempts).to eq 10
      end
    end

    describe "#guess" do
      before do
        subject.instance_variable_set(:@secret_code, [1,2,3,4])
      end

      it "decrease available attempts by 1" do
        expect { subject.guess "6666" }.to change{ subject.instance_variable_get(:@available_attempts) }.by -1
      end

      it "returns '++++' when the given code is correct" do
        expect(subject.guess "1234").to eq "++++"
      end

      it "returns '----' when the given code is correct, but numbers in different positions" do
        expect(subject.guess "4321").to eq "----"
      end

      it "returns '++' when only two matches" do
        expect(subject.guess "1654").to eq "++"
      end

      it "returns '+-' when one exact match and one not exact match" do
        expect(subject.guess "1646").to eq "+-"
      end

      it "returns '---' when three numbers in different positions" do
        expect(subject.guess "6123").to eq "---"
      end

      it "returns '+---' when only one exact match and other numbers in different positons" do
        expect(subject.guess "1423").to eq "+---"
      end

      it "returns empty string when the given code is incorrect" do
        expect(subject.guess "6666").to be_empty
      end

      it "returns 'No available attempts.' when available_attempts is zero" do
        subject.instance_variable_set(:@available_attempts, 0)
        expect(subject.guess "3232").to eq "No available attempts."
      end
    end

    describe "#hint" do
      before do
        subject.instance_variable_set(:@secret_code, [1,2,3,4])
      end

      it "change has_hint from true to false" do
        expect { subject.hint }.to change { subject.instance_variable_get(:@has_hint) }.from(true).to(false)
      end

      it "returns correct hint" do
        # Mock position
        allow(subject).to receive(:rand).and_return(2)
        expect(subject.hint).to eq "**3*"
      end

      it "returns hint in correct format" do
        expect(subject.hint).to match /^[1-6*]{4}$/
      end

      it "returns 'No hint available.' when has_hint is false" do
        subject.instance_variable_set(:@has_hint, false)
        expect(subject.hint).to eq "No hint available."
      end
    end

    describe ".render_score_table" do
      before do
        michael = Player.new("Michael", 10, 75)
        george = Player.new("George", 3, 100)
        niko = Player.new("Niko", 10, 0)

        players = []
        players << george
        players << michael
        players << niko

        allow(Player).to receive(:load_collection).and_return(players)
      end

      it "renders 'No players' when collection is empty" do
        allow(Player).to receive(:load_collection).and_return([])
        expect { Game.render_score_table }.to output(/No players\./).to_stdout
      end

      xit "renders table header correctly" do
        expect { Game.render_score_table }.to output(/^[-]{38}/).to_stdout
        expect { Game.render_score_table }.to output(/Username/).to_stdout
        expect { Game.render_score_table }.to output(/Attempts/).to_stdout
        expect { Game.render_score_table }.to output(/Complete/).to_stdout
      end

      xit "renders table body contains players" do
        expect { Game.render_score_table }.to output(/George/).to_stdout
        expect { Game.render_score_table }.to output(/Niko/).to_stdout
        expect { Game.render_score_table }.to output(/Micahel/).to_stdout
      end

    end

  end
end