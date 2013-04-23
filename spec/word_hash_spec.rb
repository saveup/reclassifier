require "spec_helper"

describe Reclassifier::Bayes do
  describe "word_hash" do
    it "should hash text" do
      hash  = {:good => 1, :"!" => 1, :hope => 1, :"'" => 1, :"." => 1, :love => 1, :word => 1, :them => 1, :test => 1}

      subject.word_hash("here are some good words of test's. I hope you love them!").should eq(hash)
    end
	end

  describe "clean_word_hash" do
    it "should clean and hash text" do
	    hash  = {:good => 1, :word => 1, :hope => 1, :love => 1, :them => 1, :test => 1}

  	  subject.clean_word_hash("here are some good words of test's. I hope you love them!").should eq(hash)
    end
  end
end
