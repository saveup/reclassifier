# gems
require 'fast-stemmer'
require 'matrix'
require 'active_support/core_ext/object/blank'

# files
require 'reclassifier/version'
require 'reclassifier/core_ext/array'
require 'reclassifier/core_ext/matrix'
require 'reclassifier/core_ext/string'
require 'gsl/vector'

module Reclassifier
  autoload :Bayes,                      'reclassifier/bayes'
  autoload :ContentNode,                'reclassifier/content_node'
  autoload :LSI,                        'reclassifier/lsi'
  autoload :UnknownClassificationError, 'reclassifier/unknown_classification_error'
  autoload :WordHash,                   'reclassifier/word_hash'
  autoload :WordList,                   'reclassifier/word_list'
end
