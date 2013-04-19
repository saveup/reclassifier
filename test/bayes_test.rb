require File.join(File.dirname(__FILE__), 'test_helper')

class BayesTest < Test::Unit::TestCase
	def setup
		@classifier = Reclassifier::Bayes.new :interesting, :uninteresting
	end

	def test_good_training
		assert_nothing_raised { @classifier.train_interesting "love" }
	end

	def test_bad_training
		assert_raise(StandardError) { @classifier.train_no_category "words" }
	end

	def test_bad_method
		assert_raise(NoMethodError) { @classifier.forget_everything_you_know "" }
	end

	def test_categories
		assert_equal [:interesting, :uninteresting].sort, @classifier.categories.sort
	end

	def test_add_category
		@classifier.add_category :test
		assert_equal [:test, :interesting, :uninteresting].sort, @classifier.categories.sort
	end

	def test_classification
		@classifier.train_interesting "here are some good words. I hope you love them"

		@classifier.train_uninteresting "here are some bad words, I hate you"

		assert_equal :uninteresting, @classifier.classify("I hate bad words and you")
	end
end
