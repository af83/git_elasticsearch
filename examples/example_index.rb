require './gitelasticsearch.rb'

DEBUG = true
repo_index = GitElasticSearch.new("/Users/git/repositories/gitlabhq.git")  

repo_index.init!
repo_index.index!
                          
