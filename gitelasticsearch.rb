require 'grit'
require 'linguist'     
require 'tire'

class GitElasticSearch 
  attr_reader :index_name
  include Grit
  Grit::Blob.class_eval { include Linguist::BlobHelper } 
    
  def initialize(git_path)
    Tire.configure do
      if DEBUG then logger STDERR end
    end  
       
    @index_name = "git_repo_#{File.basename(git_path, '.git')}"
    @index = Tire::Index.new(@index_name)

    @repo = Grit::Repo.new(git_path)
    @t = @repo.tree   
  
  end

  def init!
    @index.delete
    @index.create
  end      
  
  def index!
    recurse(@t) 
    @index.refresh
    return @index   
  end
  
  private       
    def recurse(tree, path = "")
      tree.contents.each do |c|
        case c
          when Tree
             traverse_dir c, path  
          when Blob
             index_file(c, path)
        end 
      end
    end

    def traverse_dir (c, path)
      if DEBUG then puts "#{path}#{c.name} (#{c.id})" end
      recurse(c, path + "/" + c.name)
    end       
    
    def index_file (c, path)
      if DEBUG then puts "#{path}#{c.name} (#{c.id})" end 
      if c.text? then   
        @index.store :code=> c.data.force_encoding("UTF-8"),  :_id=>c.id,:path => path, :name=>c.name 
      end
    end  

end