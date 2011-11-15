## GitElasticSearch 

Just a proof of concept  small library to index a git repo in elastic search                 

* uses grit and tire 

as per default Grit behaviour it gets the current *master*  

Could be useful with gitlabhq  

##Installation
```bash
bundle install
```
You should have a local elastic search running.
                                                  
##Usage: 

```ruby
# Inits with a full path to a local git repository
repo_index = GitElasticSearch.new("/Users/git/repositories/gitlabhq.git")  
# Inits elastic search index       
repo_index.init!
# Indexes the repo                 
repo_index.index!
```

To search the code:

```ruby
Tire.search repo_index.index_name do
   query do
     string 'mysearchterm'
   end             
end
```      
You can look at example.rb

##Todo
Well basically everything, but let's start with writing some tests and then different branches, adding the commit messages, make elastic search configurable and other fun stuff
  
##Licence 
BSD
Copyright Ori Pekelman, AF83 2011