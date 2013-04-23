module Reclassifier::WordHash
	CORPUS_SKIP_WORDS = ["a",
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
                       "youll"]

  # Return a Hash of strings => ints. Each word in the string is stemmed,
  # symbolized, and indexed to its frequency in the document.
	def word_hash(string)
		word_hash_for_words(string.gsub(/[^\w\s]/,"").split + string.gsub(/[\w]/," ").split)
	end

	# Return a word hash without extra punctuation or short symbols, just stemmed words
	def clean_word_hash(string)
		word_hash_for_words(string.gsub(/[^\w\s]/,"").split)
	end

	def word_hash_for_words(words)
		d = {}

		words.each do |word|
			word.downcase!

			key = word.stem.to_sym

			if word =~ /[^\w]/ || !CORPUS_SKIP_WORDS.include?(word) && word.length > 2
				d[key] ||= 0
				d[key] += 1
			end
		end

    d
	end

end
