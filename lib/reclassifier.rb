# gems
require 'matrix'
require 'fast-stemmer'
require 'gsl'

# files
require 'reclassifier/version'
require 'reclassifier/core_ext/array'
require 'reclassifier/core_ext/matrix'
require 'reclassifier/core_ext/string'
require 'gsl/vector'

module Reclassifier
  autoload :Bayes,       'reclassifier/bayes'
  autoload :LSI,         'reclassifier/lsi'
  autoload :ContentNode, 'reclassifier/content_node'
  autoload :WordList,    'reclassifier/word_list'
end
