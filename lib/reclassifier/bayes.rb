#
# Bayesian classifier for arbitrary text.
#
# Implementation is translated from
# <em>Introduction to Information Retrieval</em> by Christopher D. Manning,
# Prabhakar Raghavan and Hinrich Schütze, Cambridge University Press. 2008,
# ISBN 0521865719.
#
# Derived quantities are cached to improve performance of repeated #classify calls.
#
class Reclassifier::Bayes
  include Reclassifier::WordHash

  # Can be created with zero or more classifications, each of which will be
  # initialized and given a training method.  The classifications are specified as
  # an array of symbols.  Options are specified in a hash.
  #
  # Options:
  # * :clean - If false, punctuation will be included in the classifier.  Otherwise, punctuation will be omitted.  Default is true.
  #
  #
  #  b = Reclassifier::Bayes.new([:interesting, :uninteresting, :spam], :clean => true)
  #
  def initialize(classifications = [], options = {})
    @classifications = Hash.new {|h, k| h[k] = Hash.new(0)}
    @docs_in_classification_count = Hash.new(0)
    @options = options

    classifications.each {|classification| @classifications[classification]}
  end

  #
  # Provides a general training method for all classifications specified in Bayes#new
  #
  #  b = Reclassifier::Bayes.new([:this, :that])
  #  b.train(:this, "This text")
  #  b.train(:that, "That text")
  #
  def train(classification, text)
    ensure_classification_exists(classification)

    update_doc_count(classification, 1)

    smart_word_hash(text).each do |word, count|
      @classifications[classification][word] += count
    end
  end

  #
  # Untrain a (classification, text) pair.
  # Be very careful with this method.
  #
  #  b = Reclassifier::Bayes.new([:this, :that])
  #  b.train(:this, "This text")
  #  b.untrain(:this, "This text")
  #
  def untrain(classification, text)
    ensure_classification_exists(classification)

    update_doc_count(classification, -1)

    smart_word_hash(text).each do |word, count|
      @classifications[classification][word] -= count if @classifications[classification].include?(word)
    end
  end

  # Returns the scores of the specified text for each classification.
  #
  #  b.calculate_scores("I hate bad words and you")
  #  =>  {"Uninteresting"=>-12.6997928013932, "Interesting"=>-18.4206807439524}
  #
  # The largest of these scores (the one closest to 0) is the one picked out by #classify
  #
  def calculate_scores(text)
    scores = Hash.new(0.0)

    @cache[:total_docs_classified_log] ||= Math.log(@docs_in_classification_count.values.reduce(:+))
    @cache[:words_classified] ||= @classifications.values.reduce(Set.new) {|set, word_counts| set.merge(word_counts.keys)}

    @classifications.each do |classification, classification_word_counts|
      # prior
      scores[classification] = Math.log(@docs_in_classification_count[classification])
      scores[classification] -= @cache[:total_docs_classified_log]

      # likelihood
      classification_word_count = classification_word_counts.values.reduce(:+).to_i
      smart_word_hash(text).each do |word, count|
        if @cache[:words_classified].include?(word)
          scores[classification] += count * Math.log((classification_word_counts[word] || 0) + 1)

          scores[classification] -= count * Math.log(classification_word_count + @cache[:words_classified].count)
        end
      end
    end

    scores
  end

  # Returns the classification of the specified text, which is one of the
  # classifications given in the initializer.
  #
  #  b.classify("I hate bad words and you")
  #  =>  :uninteresting
  #
  def classify(text)
    calculate_scores(text.to_s).max_by {|classification| classification[1]}[0]
  end

  # Provides a list of classification names
  #
  #  b.classifications
  #  =>   [:this, :that, :the_other]
  #
  def classifications
    @classifications.keys
  end

  # Adds the classification to the classifier.
  # Has no effect if the classification already existed.
  # Returns the classification.
  #
  #  b.add_classification(:not_spam)
  #  =>  :not_spam
  #
  def add_classification(classification)
    @classifications[classification] = Hash.new(0)

    classification
  end

  #
  # Removes the classification from the classifier.
  # Returns the classifier if the classification existed, else nil.
  #
  #  b.remove_classification(:not_spam)
  #  =>  :not_spam
  #
  def remove_classification(classification)
    return_value = if @classifications.include?(classification)
                     classification
                   else
                     nil
                   end

    @classifications.delete(classification)

    return_value
  end

  # Invalidates the cache.
  #
  #  classifier = Reclassifier::Bayes.new([:one, :other])
  #
  #  classifier.train(:one, 'bbb')
  #  classifier.train(:other, 'aaa')
  #
  #  classifier.classify('aaa')
  #
  #  classifier.cache_set?
  #  =>  true
  #
  #  classifier.invalidate_cache
  #
  #  classifier.cache_set?
  #  =>  false
  #
  def invalidate_cache
    @cache = Hash.new
  end

  # Returns true if the cache has been set (i.e. #classify has been run).
  # Returns false otherwise.
  #
  #  classifier = Reclassifier::Bayes.new([:one, :other])
  #
  #  classifier.cache_set?
  #  =>  false
  #
  #  classifier.train(:one, 'bbb')
  #  classifier.train(:other, 'aaa')
  #
  #  classifier.classify('aaa')
  #
  #  classifier.cache_set?
  #  =>  true
  #
  def cache_set?
    @cache.present?
  end

  private

    def update_doc_count(classification, value)
      @docs_in_classification_count[classification] += value

      invalidate_cache
    end

    def ensure_classification_exists(classification)
      raise Reclassifier::UnknownClassificationError unless @classifications.include?(classification)
    end

    def smart_word_hash(string)
      if @options[:clean] == false
        word_hash(string)
      else
        clean_word_hash(string)
      end
    end
end
