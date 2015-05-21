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

    describe "#start" do
      before do
        $stdin = StringIO.new
      end

      it "shows 'Welcome to the Codebreaker game.'" do
        expect { subject.start }.to output(/Welcome to the Codebreaker game\./).to_stdout
      end

      it "shows 'Type your guess or ? for hint or empty to quit:'" do
        expect { subject.start }.to output(/Type your guess or \? for hint or empty to quit\:/).to_stdout
      end

      it "shows hint when gets '?'" do
        allow(subject).to receive(:hint).and_return("***3")
        fake_stdin("?") do
          expect { subject.start }.to output(/\*\*\*3/).to_stdout
        end
      end

      it "shows '++++' when gets correct code" do
        subject.instance_variable_set(:@secret_code, [1,2,3,4])
        fake_stdin("1234") do
          expect { subject.start }.to output(/\+\+\+\+/).to_stdout
        end
      end

      it "shows 'Goodbye' when gets is empty" do
        fake_stdin("") do
          expect { subject.start }.to output(/Goodbye/).to_stdout
        end
      end

      xit "asks for guess multiple times" do
        subject.instance_variable_set(:@secret_code, [6,6,6,6])
        fake_stdin("6665", "6656", "5566") do
          expect { subject.start }.to output(/(\+\+\+\-)(\+\+\+\-)(\+\+\-\-)/).to_stdout
        end
      end

      it "calls #cheat when gets iddqd" do
        expect(subject).to receive(:cheat).once
        fake_stdin("iddqd") do
          subject.start
        end
      end

      it "calls #win when given code is correct" do
        subject.instance_variable_set(:@secret_code, [6,6,6,6])
        expect(subject).to receive(:win).once
        fake_stdin("6666") do
          subject.start
        end
      end

    end

    describe "#cheat" do
      it "shows a correct secret code" do
        subject.instance_variable_set(:@secret_code, [1,2,3,4])
        expect(subject.send(:cheat)).to eq "1234"
      end
    end

    describe "#win" do

      before do
        $stdin = StringIO.new
      end

      it "shows 'You won!'" do
        expect { subject.send(:win) }.to output(/You won!/).to_stdout
      end

      it "calls #save_score" do
        expect(subject).to receive(:save_score)
        subject.send(:win)
      end
    end

    describe "#save_score" do
      before do
        $stdin = StringIO.new
      end

      it "asks 'Do you want to save your score? (yes or no)'" do
        expect(subject).to receive(:puts).with("Do you want to save your score? (yes or no)").once
        subject.send(:save_score)
      end

      it "asks for username when gets 'yes'" do
        fake_stdin("yes") do
          expect { subject.send(:save_score) }.to output(/Enter your name:/).to_stdout
        end
      end

      it "shows 'Your score is saved.' when gets username" do
        fake_stdin("yes", "George") do
          expect { subject.send(:save_score) }.to output(/Your score is saved\./).to_stdout
        end
      end

      it "calls #render_score_table" do
        expect(Game).to receive(:render_score_table).once
        fake_stdin("yes", "George") do
          subject.send(:save_score)
        end
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