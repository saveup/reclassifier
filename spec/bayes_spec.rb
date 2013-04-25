require 'spec_helper'

describe Reclassifier::Bayes do
  subject(:classifier) { Reclassifier::Bayes.new }

  shared_examples 'cache invalidator' do |method|
    it 'should invalidate the cache' do
      classifier = Reclassifier::Bayes.new([:in_china, :not_in_china])

      classifier.should_receive(:invalidate_cache)

      classifier.send(method, :in_china, 'Chinese Beijing Chinese')
    end
  end

	describe "classifications" do
    it "should return the classifications" do
      classifier = Reclassifier::Bayes.new([:interesting, :uninteresting])

      classifier.classifications.sort.should eq([:interesting, :uninteresting])
    end
	end

  describe "train" do
    it "should raise an UnknownClassificationError if the specified classification hasn't been added" do
      expect { classifier.train(:blargle, '')}.to raise_error(Reclassifier::UnknownClassificationError)
    end

    it "should train the classifier to the (classification, document) pair" do
      classifier = Reclassifier::Bayes.new([:in_china, :not_in_china])

      classifier.train(:in_china, 'Chinese Beijing Chinese')
      classifier.train(:in_china, 'Chinese Chinese Shanghai')
      classifier.train(:in_china, 'Chinese Macao')
      classifier.train(:not_in_china, 'Tokyo Japan Chinese')

      classifier.classify('Chinese Chinese Chinese Tokyo Japan').should eq(:in_china)
    end

    it_should_behave_like 'cache invalidator', :train
  end

  describe 'untrain' do
    it "should raise an UnknownClassificationError if the specified classification hasn't been added" do
      expect {classifier.untrain(:blargle, '')}.to raise_error(Reclassifier::UnknownClassificationError)
    end

    it 'should untrain the classifier against the (classification, document) pair' do
      classifier = Reclassifier::Bayes.new([:in_china, :not_in_china])

      classifier.train(:in_china, 'Chinese Chinese')
      classifier.train(:not_in_china, 'Chinese Macao')

      classifier.classify('Chinese').should eq(:in_china)

      classifier.untrain(:in_china, 'Chinese Chinese')

      classifier.classify('Chinese').should eq(:not_in_china)
    end

    it 'should not result in negative word counts'

    it_should_behave_like 'cache invalidator', :untrain
  end

  describe "calculate_scores" do
    it "should return a score hash with the correct scores" do
      classifier = Reclassifier::Bayes.new([:in_china, :not_in_china])

      classifier.train(:in_china, 'Chinese Beijing Chinese')
      classifier.train(:in_china, 'Chinese Chinese Shanghai')
      classifier.train(:in_china, 'Chinese Macao')
      classifier.train(:not_in_china, 'Tokyo Japan Chinese')

      scores = classifier.calculate_scores('Chinese Chinese Chinese Tokyo Japan')

      scores[:in_china].should eq(-8.107690312843907)
      scores[:not_in_china].should eq(-8.906681345001262)
    end

    it "should handle the case when no documents are classified for a particular classification" do
      classifier = Reclassifier::Bayes.new([:in_china, :not_in_china])

      classifier.train(:in_china, 'Chinese Beijing Chinese')

      classifier.calculate_scores('Chinese Beijing')
    end
  end

  describe "add_classification" do
    it "should add the classification to the set of classifications" do
      classifier.classifications.should be_empty

      classifier.add_classification(:niner)

      classifier.classifications.should eq([:niner])
    end

    it "should return the classification" do
      classifier.add_classification(:niner).should eq(:niner)
    end
  end

  describe "remove_classification" do
    it "should remove the classification from the set of classifications" do
      classifier.add_classification(:niner)

      classifier.remove_classification(:niner)

      classifier.classifications.should be_empty
    end

    it "should return the classification" do
      classifier.add_classification(:niner)

      classifier.remove_classification(:niner).should eq(:niner)
    end

    it "should return nil if the classification didn't exist" do
      classifier.remove_classification(:niner).should be(nil)
    end
  end

  describe 'cache_present?' do
    it 'should return true if the cache has been set' do
      classifier = Reclassifier::Bayes.new([:one, :other])

      classifier.train(:one, 'bbb')
      classifier.train(:other, 'aaa')

      classifier.classify('')

      classifier.cache_set?.should be(true)
    end

    it 'should return false if the cache has not been set' do
      classifier.cache_set?.should be(false)
    end

    it 'should return false if the cache has been invalidated' do
      classifier = Reclassifier::Bayes.new([:one, :other])

      classifier.train(:one, 'bbb')
      classifier.train(:other, 'aaa')

      classifier.classify('')

      classifier.cache_set?.should be(true)

      classifier.invalidate_cache

      classifier.cache_set?.should be(false)
    end
  end

  context ':clean option' do
    it 'should cause punctuation to be omitted if it is set to true' do
      classifier = Reclassifier::Bayes.new([:one, :other], {:clean => true})

      classifier.train(:one, '! ! ! ! bbb')
      classifier.train(:other, 'aaa')

      classifier.classify('! aaa !').should eq(:other)
    end

    it 'should default to true' do
      classifier = Reclassifier::Bayes.new([:one, :other])

      classifier.train(:one, '! ! ! ! bbb')
      classifier.train(:other, 'aaa')

      classifier.classify('! aaa !').should eq(:other)
    end

    it 'should cause punctuation not to be omitted if it is set to false' do
      classifier = Reclassifier::Bayes.new([:one, :other], {:clean => false})

      classifier.train(:one, '! ! ! ! bbb')
      classifier.train(:other, 'aaa')

      classifier.classify('! aaa !').should eq(:one)
    end
  end
end
