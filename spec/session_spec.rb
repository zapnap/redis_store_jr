require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActionController::Session::RedisSessionStore do
  before(:each) do
    @app = Object.new
    @store  = ActionController::Session::RedisSessionStore.new(@app)
    @obj = OpenStruct.new(:name => 'Test')

    with_store do |store|
      class << store
        public :get_session, :set_session
      end

      store.set_session({'rack.session.options' => {}}, 'abc', @obj)
    end
  end

  it 'should save and retrieve session information' do
    with_store do |store|
      store.set_session({ 'rack.session.options' => {} }, 'abc', @obj)
      store.get_session({}, 'abc').should === ['abc', @obj]
    end
  end

  it 'should save session data with an expiration time' do
    with_store do |store|
      store.set_session({ 'rack.session.options' => { :expires_in => 1.second } }, 'abc', @obj)
      store.get_session({}, 'abc').should === ['abc', @obj]; sleep 2
      store.get_session({}, 'abc').should === ['abc', {}]
    end
  end

  private

  def with_store
    yield @store
  end
end
