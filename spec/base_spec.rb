require File.dirname(__FILE__) + '/spec_helper'

class SpecialAsset < AssetCloud::Asset
end

class BasicCloud < AssetCloud::Base
  bucket :special, AssetCloud::MemoryBucket, :asset_class => SpecialAsset
end


describe BasicCloud do    
  directory = File.dirname(__FILE__) + '/files'
                    
  before do
    @fs = BasicCloud.new(directory , 'http://assets/files' )
  end                          
    
  it "should raise invalid bucket if none is given" do
    @fs['image.jpg'].exist?.should == false
  end

  
  it "should be backed by a file system bucket" do     
    @fs['products/key.txt'].exist?.should == true    
  end
  
  it "should raise when listing non existing buckets" do
    @fs.ls('products').should == [AssetCloud::Asset.new(@fs, 'products/key.txt')]
  end
                
 
  it "should allow you to create new assets" do
    obj = @fs.build('new_file.test')
    obj.should be_an_instance_of(AssetCloud::Asset)
    obj.cloud.should be_an_instance_of(BasicCloud)
  end                  
  
  it "should raise error when using with minus relative or absolute paths" do    
    lambda { @fs['../test']  }.should raise_error(AssetCloud::IllegalPath)
    lambda { @fs['/test']    }.should raise_error(AssetCloud::IllegalPath)
    lambda { @fs['.../test'] }.should raise_error(AssetCloud::IllegalPath)
    lambda { @fs['./test']   }.should raise_error(AssetCloud::IllegalPath)
  end                                                                         
  
  it "should allow sensible relative filenames" do
    @fs['assets/rails_logo.gif']
    @fs['assets/rails-2.gif']
    @fs['assets/223434.gif']
    @fs['files/1.JPG']
  end
  
  it "should compute complete urls to assets" do    
    @fs.url_for('products/key with spaces.txt').should == 'http://assets/files/products/key%20with%20spaces.txt'
  end                                               
  
  describe "#find" do
    it "should return the appropriate asset when one exists" do
      asset = @fs.find('products/key.txt')
      asset.key.should == 'products/key.txt'
      asset.value.should == 'value'
    end
    it "should raise AssetNotFoundError when the asset doesn't exist" do
      lambda { @fs.find('products/not-there.txt') }.should raise_error(AssetCloud::AssetNotFoundError)
    end
  end
  
  describe "#[]" do
    it "should return the appropriate asset when one exists" do
      asset = @fs['products/key.txt']
      asset.key.should == 'products/key.txt'
      asset.value.should == 'value'
    end
    it "should not raise any errors when the asset doesn't exist" do
      lambda { @fs['products/not-there.txt'] }.should_not raise_error
    end
  end
  
  describe "#[]=" do
    it "should write through the Asset object (and thus run any callbacks on the asset)" do
      special_asset = mock(:special_asset)
      special_asset.should_receive(:value=).with('fancy fancy!')
      special_asset.should_receive(:store)
      SpecialAsset.should_receive(:at).and_return(special_asset)
      @fs['special/fancy.txt'] = 'fancy fancy!'
    end
  end
  
  describe "#bucket" do
    it "should allow specifying a class to use for assets in this bucket" do
      @fs['assets/rails_logo.gif'].should be_instance_of(AssetCloud::Asset)
      @fs['special/fancy.txt'].should be_instance_of(SpecialAsset)
      
      @fs.build('assets/foo').should be_instance_of(AssetCloud::Asset)
      @fs.build('special/foo').should be_instance_of(SpecialAsset)
    end
  end
                
end