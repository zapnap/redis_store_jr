require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RedisStore::MarshalledClient do
  before(:each) do
    @store = RedisStore::MarshalledClient.new
    @obj = OpenStruct.new(:name => 'Test')
    @store.marshalled_set('abc', @obj)
  end

  after(:each) do
    @store.quit
  end

  it 'should unmarshal an object on get' do
    @store.marshalled_get('abc').should === @obj
  end

  it 'should marshal object on set' do
    @store.marshalled_set('abc', @obj)
    @store.marshalled_get('abc').should === @obj
  end

  it 'should not unmarshal object on get if raw option is true' do
    @store.marshalled_get('abc', :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\tTest"
  end

  it 'should not marshal object on set if raw option is true' do
    @store.marshalled_set('abc', @obj, :raw => true)
    @store.marshalled_get('abc', :raw => true).should == %(#<OpenStruct name="Test">)
  end

  it 'should not unmarshal object if getting an empty string' do
    @store.marshalled_set('empty_string', '')
    lambda { @store.marshalled_get('empty_string').should == '' }.should_not raise_error
  end

  it 'should not set an object if it already exists' do
    new = OpenStruct.new(:name => 'New')
    @store.marshalled_setnx('abc', new)
    @store.marshalled_get('abc').should === @obj
  end

  it 'should marshal object on set_unless_exists' do
    @store.marshalled_setnx('def', @obj)
    @store.marshalled_get('def').should === @obj
  end

  it 'should not marshal object on set_unless_exists if raw option is true' do
    @store.marshalled_setnx('def', @obj, :raw => true)
    @store.marshalled_get('def', :raw => true).should == "\004\bU:\017OpenStruct{\006:\tname\"\tTest"
  end
end
