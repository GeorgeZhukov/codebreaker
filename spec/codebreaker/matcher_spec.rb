require 'spec_helper'

module Codebreaker
  describe Matcher do
    subject { Matcher.new([1,2,3,4], [4,3,2,1] ) }
    describe "#new" do
      it "accepts secret and guess codes" do
        expect { subject }.not_to raise_exception
      end
      
      it "saves secret code" do
        expect(subject.instance_variable_get(:@secret_code)).to eq [1,2,3,4]
      end
      
      it "saves guess code" do
        expect(subject.instance_variable_get(:@guess_code)).to eq [4,3,2,1]        
      end
      
      it "init @just_match to zero" do
        expect(subject.just_match).to be_zero
      end
      
      it "init @exact_match to zero" do
        expect(subject.exact_match).to be_zero
      end
    end
    
    describe "#calc" do
      it "calls #calc_exact_match" do
        expect(subject).to receive(:calc_exact_match).once
        subject.calc
      end
      
      it "calls #calc_just_match" do
        expect(subject).to receive(:calc_just_match).once
        subject.calc
      end
      
      context "calculation" do
        
        describe "@exact_match" do
          samples = [
            [[1,2,3,4], [1,2,3,6], 3],
            [[1,2,3,4], [1,2,6,6], 2],
            [[1,2,3,4], [5,5,3,4], 2],
            [[1,2,3,4], [1,2,3,4], 4],
            [[1,2,3,4], [4,3,2,1], 0],
          ]
          
          samples.each do |s,g,m|
            it "correctly calculate exact match when secret code is #{s}, guess code is #{g}" do
              matcher = Matcher.new(s,g)
              matcher.calc
              expect(matcher.exact_match).to eq m
            end
          end
        end
        
        describe "@just_match" do
          samples = [
            [[1,2,3,4], [1,2,3,6], 0],
            [[1,2,3,4], [1,2,6,6], 0],
            [[1,2,3,4], [4,3,2,1], 4],
            [[1,2,3,4], [4,3,5,5], 2],
            [[1,2,3,4], [4,3,2,3], 3],
          ]
          
          samples.each do |s,g,m|
            it "correctly calculate just match when secret code is #{s}, guess code is #{g}" do
              matcher = Matcher.new(s,g)
              matcher.calc
              expect(matcher.just_match).to eq m
            end
          end
        end
             
      end
      
    end

  end
end