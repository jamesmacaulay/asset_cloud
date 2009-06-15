require File.dirname(__FILE__) + '/spec_helper'
                                                    
class MemoryBucket < AssetCloud::Base
  bucket :memory, AssetCloud::MemoryBucket
end

describe MemoryBucket do    
  directory = File.dirname(__FILE__) + '/files'
                    
  before do
    @fs = MemoryBucket.new(directory , 'http://assets/files' )
  end                        
    

  describe 'modifying items in subfolder' do
    
    it "should return nil when file does not exist" do
      @fs['memory/essay.txt'].exist?.should == false
    end
    
    it "should return return set content when asked for the same file" do
      @fs['memory/essay.txt'] = 'text'
      @fs['memory/essay.txt'].value.should == 'text'
    end
    
  end
  


end