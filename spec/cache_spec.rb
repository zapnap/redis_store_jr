require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveSupport::Cache::RedisStore do
  before(:each) do
    @store  = ActiveSupport::Cache::RedisStore.new('localhost:6379')
    @store.clear

    @obj = OpenStruct.new(:name => 'Test')
    @store.write('abc', @obj)
  end

  it 'should read and write data' do
    with_store do |store|
      store.write('abc', @obj)
      store.read('abc').should == @obj
    end
  end

  it 'should read and write data with an expiration' do
    with_store do |store|
      store.write('abc', @obj, :expires_in => 1.second)
      store.read('abc').should == @obj ; sleep 2
      store.read('abc').should be_nil
    end
  end

  it 'should only write data if not already set' do
    with_store do |store|
      new = OpenStruct.new(:name => 'New')
      store.write('abc', new, :unless_exist => true)
      store.read('abc').should == @obj
    end
  end

  it 'should read raw data' do
    with_store do |store|
      store.read('abc', :raw => true).should == Marshal.dump(@obj)
    end
  end

  it 'should write raw data' do
    with_store do |store|
      store.write('abc', @obj, :raw => true)
      store.read('abc', :raw => true).should == %(#<OpenStruct name="Test">)
    end
  end

  it 'should delete data' do
    with_store do |store|
      store.delete('abc')
      store.read('abc').should be_nil
    end
  end

  it 'should delete matched data given a string glob matcher' do
    with_store do |store|
      store.write('abd', @obj)
      store.write('axe', @obj)

      store.delete_matched('ab*')
      store.read('abc').should be_nil
      store.read('abd').should be_nil
      store.read('axe').should_not be_nil
    end
  end

  it 'should delete matched data given a regexp'

  it 'should verify existence of an object' do
    with_store do |store|
      store.exist?('abd').should be_false
      store.exist?('abc').should be_true
    end
  end

  it 'should increment a key' do
    with_store do |store|
      3.times { store.increment('ct') }
      store.read('ct', :raw => true).to_i.should == 3
    end
  end

  it 'should decrement a key' do
    with_store do |store|
      3.times { store.increment('ct') }
      2.times { store.decrement('ct') }
      store.read('ct', :raw => true).to_i.should == 1
    end
  end

  it 'should increment a key by a given value' do
    with_store do |store|
      store.increment('ct')
      store.increment('ct', 3)
      store.read('ct', :raw => true).to_i.should == 4
    end
  end

  it 'should decrement a key by a given value' do
    with_store do |store|
      3.times { store.increment('ct') }
      store.decrement('ct', 2)
      store.read('ct', :raw => true).to_i.should == 1
    end
  end

  it 'should clear the store' do
    with_store do |store|
      store.clear
      store.read('abc').should be_nil
    end
  end

  it 'should return store stats' do
    with_store do |store|
      store.stats.should_not be_nil
    end
  end

  private

  def with_store
    yield @store
  end
end
