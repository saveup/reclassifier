require 'classifier_comes_alive/version'
require 'classifier_comes_alive/core_ext/array'
require 'classifier_comes_alive/core_ext/matrix'
require 'classifier_comes_alive/core_ext/object'
require 'classifier_comes_alive/core_ext/string'
require 'gsl'

module ClassifierComesAlive
  autoload :Bayes,       'classifier_comes_alive/bayes'
  autoload :LSI,         'classifier_comes_alive/lsi'
  autoload :ContentNode, 'classifier_comes_alive/content_node'
  autoload :WordList,    'classifier_comes_alive/word_list'
end
