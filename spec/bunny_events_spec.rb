require 'bunny-mock'

RSpec.describe BunnyEvents do

  let(:mock_bunny) {}
  let(:bunny_events) {  BunnyEvents.new }

  it "should not be connected by default" do
    expect(bunny_events.connected?).to be false
  end

  describe "initialising BunnyEvents with mock bunny connection" do

    it "should fail with no valid bunny connection" do
      expect{bunny_events.init nil}.to raise_error Exceptions::InvalidBunnyConnection
      expect{bunny_events.init Object.new}.to raise_error Exceptions::InvalidBunnyConnection
    end

    it "should work if a valid bunny connection is passed" do
      bunny_events.init BunnyMock.new.start

      expect(bunny_events.connected?).to be(true)
    end
  end

  describe "publishing an event" do
    before(:each) do
      bunny_events.init BunnyMock.new.start
    end

    let(:valid_event) { DummyEvent.new "test" }
    let(:fanout_event) {DummyFanoutEvent.new "test"}

    it "should fail if a non-BunnyEvent was passed" do
      expect{bunny_events.publish nil}.to raise_error Exceptions::InvalidBunnyEvent
    end

    it "should pass and create queues and exchanges if a valid BunnyEvent was passed" do
      expect{bunny_events.publish valid_event}.not_to raise_error
      expect(bunny_events.bunny_connection.exchange_exists?('test_exchange')).to be_truthy
      expect(bunny_events.bunny_connection.queue_exists?('test_queue')).to be_truthy
    end
  end

end