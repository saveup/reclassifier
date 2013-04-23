#
# Bayesian classifier for arbitrary text.
#
# Implementation is translated from
# <em>Introduction to Information Retrieval</em> by Christopher D. Manning, Prabhakar Raghavan and Hinrich Schütze,
# Cambridge University Press. 2008, ISBN 0521865719.
#
class Reclassifier::Bayes
  include Reclassifier::WordHash

  # Can be created with zero or more classifications, each of which will be
  # initialized and given a training method.  The classifications are specified as
  # an array of symbols.  Options are specified in a hash.
  #
  # Options:
  # * :clean - If true, non-word characters (e.g. punctuation) will be removed.  Otherwise, non-word characters will be processed.  Default is false.
  #
  #      b = Reclassifier::Bayes.new([:interesting, :uninteresting, :spam], :clean => true)
  def initialize(classifications = [], options = {})
    @classifications = {}
    classifications.each {|classification| @classifications[classification] = {}}

    @docs_in_classification_count = {}

    @options = options
  end

  #
  # Provides a general training method for all classifications specified in Bayes#new
  # For example:
  #     b = Reclassifier::Bayes.new :this, :that
  #     b.train :this, "This text"
  #     b.train :that, "That text"
  def train(classification, text)
    ensure_classification_exists(classification)

    @docs_in_classification_count[classification] ||= 0
    @docs_in_classification_count[classification] += 1

    word_hash(text).each do |word, count|
      @classifications[classification][word] ||= 0

      @classifications[classification][word] += count
    end
  end

  #
  # Untrain a (classification, text) pair.
  # Be very careful with this method.
  #
  # For example:
  #     b = Reclassifier::Bayes.new :this, :that, :the_other
  #     b.train :this, "This text"
  #     b.untrain :this, "This text"
  def untrain(classification, text)
    ensure_classification_exists(classification)

    @docs_in_classification_count[classification] -= 1

    word_hash(text).each do |word, count|
      @classifications[classification][word] -= count if @classifications[classification].include?(word)
    end
  end

  #
  # Returns the scores of the specified text for each classification. E.g.,
  #    b.classifications "I hate bad words and you"
  #    =>  {"Uninteresting"=>-12.6997928013932, "Interesting"=>-18.4206807439524}
  # The largest of these scores (the one closest to 0) is the one picked out by #classify
  def calculate_scores(text)
    scores = {}

    @classifications.each do |classification, classification_word_counts|
      # prior
      scores[classification] = Math.log(@docs_in_classification_count[classification])
      scores[classification] -= Math.log(@docs_in_classification_count.values.reduce(:+))

      # likelihood
      word_hash(text).each do |word, count|
        if @classifications.values.reduce(Set.new) {|set, word_counts| set.merge(word_counts.keys)}.include?(word)
          scores[classification] += count * Math.log((classification_word_counts[word] || 0) + 1)

          scores[classification] -= count * Math.log(classification_word_counts.values.reduce(:+) + @classifications.values.reduce(Set.new) {|set, word_counts| set.merge(word_counts.keys)}.count)
        end
      end
    end

    scores
  end

  #
  # Returns the classification of the specified text, which is one of the
  # classifications given in the initializer. E.g.,
  #    b.classify "I hate bad words and you"
  #    =>  :uninteresting
  def classify(text)
    calculate_scores(text).max_by {|classification| classification[1]}[0]
  end

  #
  # Provides a list of classification names
  # For example:
  #     b.classifications
  #     =>   [:this, :that, :the_other]
  def classifications
    @classifications.keys
  end

  #
  # Adds the classification to the classifier.
  # Has no effect if the classification already existed.
  # Returns the classification.
  # For example:
  #     b.add_classification(:not_spam)
  def add_classification(classification)
    @classifications[classification] ||= {}

    classification
  end

  #
  # Removes the classification from the classifier.
  # Returns the classifier if the classification existed, else nil.
  # For example:
  #     b.remove_classification(:not_spam)
  def remove_classification(classification)
    return_value = if @classifications.include?(classification)
                     classification
                   else
                     nil
                   end

    @classifications.delete(classification)

    return_value
  end

  private

    def ensure_classification_exists(classification)
      raise Reclassifier::UnknownClassificationError unless @classifications.include?(classification)
    end
end
