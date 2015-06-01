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

      it "sets available_attempts to 10" do
        expect(subject.instance_variable_get(:@available_attempts)).to eq 10
      end

      it "uses random numbers to generate a secret code" do
        allow_any_instance_of(Game).to receive(:rand).and_return(1,2,3,4)
        game = Game.new
        expect(game.instance_variable_get(:@secret_code)).to eq [1,2,3,4]
      end

      it "saves complete" do
        expect(subject.instance_variable_defined?(:@complete)).to be true
      end

      it "sets complete to zero" do
        expect(subject.instance_variable_get(:@complete)).to be_zero
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

    describe "complete" do
      it "has getter" do
        expect(subject.complete).to eq 0
      end
    end

    describe "#guess" do
      before do
        subject.instance_variable_set(:@secret_code, [1,2,3,4])
      end

      it "update change @complete from 0 to 25 when 1 exact match" do
        expect { subject.guess "1555" }.to change { subject.instance_variable_get(:@complete) }.from(0).to(25)
      end

      it "update change @complete from 25 to 50 when 2 exact match" do
        subject.instance_variable_set(:@complete, 25)
        expect { subject.guess "1255" }.to change { subject.instance_variable_get(:@complete) }.from(25).to(50)
      end

      it "doesn't update @complete from 50 to 25 when 1 exact match after 2 exact match" do
        subject.instance_variable_set(:@complete, 50)
        expect { subject.guess "1555" }.not_to change { subject.instance_variable_get(:@complete) }
      end

      it "decrease available attempts by 1" do
        expect { subject.guess "6666" }.to change{ subject.instance_variable_get(:@available_attempts) }.by -1
      end

      sample_data = {
         "1234": "++++",
         "1235": "+++",
         "1236": "+++",
         "1243": "++--",
         "1245": "++-",
         "1246": "++-",
         "1253": "++-",
         "1254": "+++",
         "1256": "++",
         "1263": "++-",
         "1264": "+++",
         "1265": "++",
         "1324": "++--",
         "1325": "+--",
         "1326": "+--",
         "1342": "+---",
         "1345": "+--",
         "1346": "+--",
         "1352": "+--",
         "1354": "++-",
         "1356": "+-",
         "1362": "+--",
         "1364": "++-",
         "1365": "+-",
         "1423": "+---",
         "1425": "+--",
         "1426": "+--",
         "1432": "++--",
         "1435": "++-",
         "1436": "++-",
         "1452": "+--",
         "1453": "+--",
         "1456": "+-",
         "1462": "+--",
         "1463": "+--",
         "1465": "+-",
         "1523": "+--",
         "1524": "++-",
         "1526": "+-",
         "1532": "++-",
         "1534": "+++",
         "1536": "++",
         "1542": "+--",
         "1543": "+--",
         "1546": "+-",
         "1562": "+-",
         "1563": "+-",
         "1564": "++",
         "1623": "+--",
         "1624": "++-",
         "1625": "+-",
         "1632": "++-",
         "1634": "+++",
         "1635": "++",
         "1642": "+--",
         "1643": "+--",
         "1645": "+-",
         "1652": "+-",
         "1653": "+-",
         "1654": "++",
         "2134": "++--",
         "2135": "+--",
         "2136": "+--",
         "2143": "----"
      };

      sample_data.each do |k,v|
        it "returns #{v} when #{k}" do 
          expect(subject.guess k.to_s).to eq v
        end
      end

      context "give all possible variants" do
        sample_data = (1..6).to_a.permutation(4).map(&:join)

        sample_data.each do |code|
          it do 
            expect(subject.guess code).to match /[1-6]{0,4}/
          end
        end
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

      it "returns correct hint" do
        # Mock position
        allow(subject).to receive(:rand).and_return(2)
        expect(subject.hint).to eq "**3*"
      end

      it "returns hint in correct format" do
        expect(subject.hint).to match /^[1-6*]{4}$/
      end

      it "sets correct @hint" do
        # Mock position
        allow(subject).to receive(:rand).and_return(2)
        subject.hint
        expect(subject.instance_variable_get(:@hint)).to eq "**3*"
      end

      it "returns @hint if not nil" do
        subject.instance_variable_set(:@hint, "**3*")
        expect(subject.hint).to eq "**3*"
      end      
    end   

  end
end
