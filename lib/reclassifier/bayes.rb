module Reclassifier
  class Bayes
    # The class can be created with one or more categories, each of which will be
    # initialized and given a training method.  The categories are specified as
    # symbols.  E.g.,
    #      b = Reclassifier::Bayes.new :interesting, :uninteresting, :spam
    def initialize(*categories)
      @categories = {}

      categories.each { |category| @categories[category] = {} }

      @total_words = 0

      @category_counts = Hash.new(0)
    end

    #
    # Provides a general training method for all categories specified in Bayes#new
    # For example:
    #     b = Reclassifier::Bayes.new :this, :that, :the_other
    #     b.train :this, "This text"
    #     b.train :that, "That text"
    #     b.train the_other, "The other text"
    def train(category, text)
      @category_counts[category] += 1

      text.word_hash.each do |word, count|
        @categories[category][word] ||= 0
        @categories[category][word] += count

        @total_words += count
      end
    end

    #
    # Provides an untraining method for all categories specified in Bayes#new
    # Be very careful with this method.
    #
    # For example:
    #     b = Reclassifier::Bayes.new :this, :that, :the_other
    #     b.train :this, "This text"
    #     b.untrain :this, "This text"
    def untrain(category, text)
      @category_counts[category] -= 1

      text.word_hash.each do |word, count|
        if @total_words >= 0
          orig = @categories[category][word]

          @categories[category][word] ||= 0
          @categories[category][word] -= count

          if @categories[category][word] <= 0
            @categories[category].delete(word)
            count = orig
          end

          @total_words -= count
        end
      end
    end

    #
    # Returns the scores in each category the provided +text+. E.g.,
    #    b.classifications "I hate bad words and you"
    #    =>  {"Uninteresting"=>-12.6997928013932, "Interesting"=>-18.4206807439524}
    # Explained here: http://nlp.stanford.edu/IR-book/html/htmledition/naive-bayes-text-classification-1.html
    # The largest of these scores (the one closest to 0) is the one picked out by #classify
    def classifications(text)
      score = {}

      total_category_counts = @category_counts.values.inject(:+).to_f

      @categories.each do |category, word_counts|
        score[category] = 0

        total = word_counts.values.inject(:+).to_f

        text.word_hash.keys.each do |word|
          score[category] += Math.log(word_counts[word] / total) if word_counts.has_key?(word)
        end

        # now add prior probability for the category
        score[category] += Math.log(@category_counts[category] / total_category_counts)
      end

      score
    end

    #
    # Returns the classification of the provided +text+, which is one of the
    # categories given in the initializer. E.g.,
    #    b.classify "I hate bad words and you"
    #    =>  'Uninteresting'
    def classify(text)
      (classifications(text).sort_by { |a| -a[1] })[0][0]
    end

    #
    # Provides training and untraining methods for the categories specified in Bayes#new
    # For example:
    #     b = Reclassifier::Bayes.new 'This', 'That', 'the_other'
    #     b.train_this "This text"
    #     b.train_that "That text"
    #     b.untrain_that "That text"
    #     b.train_the_other "The other text"
    def method_missing(name, *args)
      category = name.to_s.gsub(/(un)?train_([\w]+)/, '\2').to_sym

      if @categories.has_key?(category)
        args.each { |text| eval("#{$1}train(category, text)") }
      elsif name.to_s =~ /(un)?train_([\w]+)/
        raise StandardError, "No such category: #{category}"
      else
        super  #raise StandardError, "No such method: #{name}"
      end
    end

    #
    # Provides a list of category names
    # For example:
    #     b.categories
    #     =>   [:this, :that, :the_other]
    def categories # :nodoc:
      @categories.keys
    end

    #
    # Allows you to add categories to the classifier.
    # For example:
    #     b.add_category "Not spam"
    #
    # WARNING: Adding categories to a trained classifier will
    # result in an undertrained category that will tend to match
    # more criteria than the trained selective categories. In short,
    # try to initialize your categories at initialization.
    def add_category(category)
      @categories[category] = {}
    end

    alias append_category add_category
  end
end
