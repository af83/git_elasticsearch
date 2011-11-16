require './gitelasticsearch.rb'
DEBUG = true

repo_index = GitElasticSearch.new("/Users/git/repositories/gitlabhq.git")  
repo_index.refresh

s = Tire.search repo_index.index_name do
   query do       
    boolean do
     should {string 'code:*j*'}
     should {terms :branch, ['pratica'] }
    end                                  
   end             
   facet 'language' do
     terms :language
   end             
   facet 'timeline' do
     date   :date, :interval => 'month' 
   end
   highlight :code=> { :number_of_fragments => 0 }, :options => { :tag => "<span class=\"highlight\">" }
end
puts "<h1>Facets:</h1><pre>"
s.results.facets['language']['terms'].each do |f|
  puts "#{f['term'].ljust(10)} #{f['count']}"
end
 s.results.facets['timeline']['terms'].each do |f|
  puts "#{f['term'].ljust(10)} #{f['count']}"
end
puts "</pre><hr>"                      
                 
s.results.each do |document|
  puts "<h1>#{document.path}/#{document.name} @ #{document.branch} </h1>" 
  if document.highlight.nil?  then
    puts "<strong>ERROR ERROR ERROR</strong>"
  else                                                   
     puts document.highlight.code.join("")  
  end
end
puts "<style>#{Pygments.css}</style>"
