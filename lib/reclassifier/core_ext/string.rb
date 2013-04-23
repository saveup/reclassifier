class String

  # Return a Hash of strings => ints. Each word in the string is stemmed,
  # symbolized, and indexed to its frequency in the document.
	def word_hash
		word_hash_for_words(gsub(/[^\w\s]/,"").split + gsub(/[\w]/," ").split)
	end

	# Return a word hash without extra punctuation or short symbols, just stemmed words
	def clean_word_hash
		word_hash_for_words gsub(/[^\w\s]/,"").split
	end

	def word_hash_for_words(words)
		d = Hash.new
		words.each do |word|
			word.downcase! if word =~ /[\w]+/
			key = word.stem.to_sym
			if word =~ /[^\w]/ || ! CORPUS_SKIP_WORDS.include?(word) && word.length > 2
				d[key] ||= 0
				d[key] += 1
			end
		end
		return d
	end

	CORPUS_SKIP_WORDS = [
      "a",
      "again",
      "all",
      "along",
      "are",
      "also",
      "an",
      "and",
      "as",
      "at",
      "but",
      "by",
      "came",
      "can",
      "cant",
      "couldnt",
      "did",
      "didn",
      "didnt",
      "do",
      "doesnt",
      "dont",
      "ever",
      "first",
      "from",
      "have",
      "her",
      "here",
      "him",
      "how",
      "i",
      "if",
      "in",
      "into",
      "is",
      "isnt",
      "it",
      "itll",
      "just",
      "last",
      "least",
      "like",
      "most",
      "my",
      "new",
      "no",
      "not",
      "now",
      "of",
      "on",
      "or",
      "should",
      "sinc",
      "so",
      "some",
      "th",
      "than",
      "this",
      "that",
      "the",
      "their",
      "then",
      "those",
      "to",
      "told",
      "too",
      "true",
      "try",
      "until",
      "url",
      "us",
      "were",
      "when",
      "whether",
      "while",
      "with",
      "within",
      "yes",
      "you",
      "youll",
      ]

   def summary( count=10, separator=" [...] " )
      perform_lsi split_sentences, count, separator
   end

   def paragraph_summary( count=1, separator=" [...] " )
      perform_lsi split_paragraphs, count, separator
   end

   def split_sentences
      split /(\.|\!|\?)/ # TODO: make this less primitive
   end

   def split_paragraphs
      split /(\n\n|\r\r|\r\n\r\n)/ # TODO: make this less primitive
   end

   private

   def perform_lsi(chunks, count, separator)
      lsi = Reclassifier::LSI.new :auto_rebuild => false
      chunks.each { |chunk| lsi << chunk unless chunk.strip.empty? || chunk.strip.split.size == 1 }
      lsi.build_index
      summaries = lsi.highest_relative_content count
      return summaries.reject { |chunk| !summaries.include? chunk }.map { |x| x.strip }.join(separator)
   end
end
