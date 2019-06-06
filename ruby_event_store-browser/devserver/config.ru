require 'ruby_event_store'
require_relative "../lib/ruby_event_store/browser/app"

repository = RubyEventStore::InMemoryRepository.new
event_store = RubyEventStore::Client.new(repository: repository)

event_store.subscribe_to_all_events(RubyEventStore::LinkByCorrelationId.new(event_store: event_store))

DummyEvent = Class.new(::RubyEventStore::Event)
OtherEvent = Class.new(::RubyEventStore::Event)

90.times do
  event_store.publish(DummyEvent.new(
    data: {
      some_integer_attribute: 42,
      some_string_attribute: "foobar",
      some_float_attribute: 3.14,
    }
  ), stream_name: "DummyStream$78")
end


some_correlation_id = "469904c5-46ee-43a3-857f-16a455cfe337"
event_store.publish(OtherEvent.new(
  data: {
    some_integer_attribute: 42,
    some_string_attribute: "foobar",
    some_float_attribute: 3.14,
  },
  metadata: {
    correlation_id: some_correlation_id,
  },
), stream_name: "OtherStream$91")
3.times do
  event_store.publish(DummyEvent.new(
    data: {
      some_integer_attribute: 42,
      some_string_attribute: "foobar",
      some_float_attribute: 3.14,
    },
    metadata: {
      correlation_id: some_correlation_id,
    },
  ), stream_name: "DummyStream$79")
end

run RubyEventStore::Browser::App.for(
  event_store_locator: -> { event_store },
)
