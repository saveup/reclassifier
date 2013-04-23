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

    it 'should convert non-word characters to spaces' do
      subject.clean_word_hash('Payment-Transfer').should eq(:payment => 1, :transfer => 1)
    end
  end

  [:word_hash, :clean_word_hash].each do |method|
    it "#{method} should trim each word" do
      subject.send(method, "test    test123   \t\t\t aaa").should eq(:test => 1, :test123 => 1, :aaa => 1)
    end
  end
end
