require './gitelasticsearch.rb'
require 'pygments'
DEBUG = true
repo_index = GitElasticSearch.new("/Users/git/repositories/gitlabhq.git")  

repo_index.init!
repo_index.index!
                          
s = Tire.search repo_index.index_name do
   query do
     string 'admin'
   end             
end
                                       
s.results.each do |document|
  puts "<h1>#{document.path}#{document.name}</h1>"    
  puts Pygments.highlight(document.code)
end
puts "<style>#{Pygments.css}</style>"