require File.join(File.dirname(__FILE__), 'test_helper')

class BayesTest < Test::Unit::TestCase
	def setup
		@classifier = Reclassifier::Bayes.new(:interesting, :uninteresting)
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

  def test_classifications
    classifier = Reclassifier::Bayes.new

    classifier.instance_variable_set(:@categories, {:in_china     => {'Chinese' => 5, 'Beijing' => 1, 'Shanghai' => 1, 'Macao' => 1},
                                                    :not_in_china => {'Chinese' => 1, 'Tokyo' => 1, 'Japan' => 1}})

    classifier.instance_variable_set(:@docs_in_category_count, {:in_china => 3, :not_in_china => 1})

    classifications = classifier.classifications({'Chinese' => 3, 'Tokyo' => 1, 'Japan' => 1})

    assert_equal -8.107690312843907, classifications[:in_china]
    assert_equal -8.906681345001262, classifications[:not_in_china]
  end
end
