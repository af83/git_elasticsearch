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
  
  end

  def init!
    @index.delete
    @index.create
  end      
         
  def index!                         
    @repo.branches.map{|branch|recurse(@repo.tree(branch.name), branch.name)} # @fixme this woefully inefficient, we are repeating in the index each blob, even it it is the same in each branch; This also makes it hard to get the authored, date info. The whole thing should probably index through traversing commits and not the tree through branches. This shows just how awsome and efficient git is.
    return @index   
  end

  def refresh
    @index.refresh
  end        
  
  private       
    def recurse(tree, path = "", branch_name)
      tree.contents.each do |c|
        case c
          when Tree
             traverse_dir c, path, branch_name  
          when Blob
             index_file(c, path, branch_name)
        end 
      end
    end

    def traverse_dir (c, path, branch_name)
      if DEBUG then puts "#{path}/#{c.name} (#{c.id}) @#{branch_name}" end
      recurse(c, path + "/" + c.name, branch_name)
    end       
    
    def index_file (c, path, branch_name)
      if DEBUG then puts "#{path}/#{c.name} (#{c.id}) @#{branch_name} " end 
      if c.text? then   
        @index.store :code=> c.colorize,  :_id=>"#{c.id}@#{branch_name}",:path => path, :name=>c.name, :branch => branch_name, :language =>c.language , :date=>@authored_date#, :author=>c.author_string, :date=>c.date
        #puts c.methods.inspect 
      end
    end  

end