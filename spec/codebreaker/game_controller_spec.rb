require 'spec_helper'

module Codebreaker
  describe GameController do
    before do
      $stdout = StringIO.new
      $stdin = StringIO.new
    end

    describe "#initialize" do
      it "saves game" do
        expect(subject.instance_variable_get(:@game)).not_to be_nil
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
        allow(subject.instance_variable_get(:@game)).to receive(:hint).and_return("***3")
        fake_stdin("?") do
          expect { subject.start }.to output(/\*\*\*3/).to_stdout
        end
      end

      it "shows 'Unknown command' when gets command in wrong format" do
        fake_stdin("qwerty") do
          expect { subject.start }.to output(/Unknown command/).to_stdout
        end
        fake_stdin("6767") do
          expect { subject.start }.to output(/Unknown command/).to_stdout
        end
        fake_stdin("  9") do
          expect { subject.start }.to output(/Unknown command/).to_stdout
        end
      end

      it "shows '++++' when gets correct code" do
        game = subject.instance_variable_get(:@game)
        game.instance_variable_set(:@secret_code, [1,2,3,4])
        fake_stdin("1234") do
          expect { subject.start }.to output(/\+\+\+\+/).to_stdout
        end
      end

      it "shows 'Goodbye' when gets is empty" do
        fake_stdin("") do
          expect { subject.start }.to output(/Goodbye/).to_stdout
        end
      end

      it "calls #cheat when gets iddqd" do
        expect(subject.instance_variable_get(:@game)).to receive(:cheat).once
        fake_stdin("iddqd") do
          subject.start
        end
      end

      it "calls #win when given code is correct" do
        game = subject.instance_variable_get(:@game)
        game.instance_variable_set(:@secret_code, [6,6,6,6])
        expect(subject).to receive(:win).once
        fake_stdin("6666") do
          subject.start
        end
      end

    end

    describe "#save_score" do
      before do
        $stdin = StringIO.new

        # Mock file operations
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:write)
        allow(File).to receive(:read)
        allow(Marshal).to receive(:load).and_return([])
        allow(Marshal).to receive(:dump)
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

    describe "#win" do

      it "shows 'You won!'" do
        expect { subject.send(:win) }.to output(/You won!/).to_stdout
      end

      it "calls #save_score" do
        expect(subject).to receive(:save_score)
        subject.send(:win)
      end
    end
  end
end