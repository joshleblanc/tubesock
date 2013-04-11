require 'test_helper'

class TubesockTest < Tubesock::TestCase

  def test_raise_exception_when_hijack_is_not_available
    -> {
      Tubesock.hijack({})
    }.must_raise Tubesock::HijackNotAvailable
  end

  def test_hijack
    interaction = TestInteraction.new

    opened = MockProc.new
    closed = MockProc.new

    interaction.tubesock do |tubesock|
      tubesock.onopen  &opened
      tubesock.onclose &closed

      tubesock.onmessage do |message|
        tubesock.send_data message: "Hello #{message["name"]}"
      end
    end

    interaction.write name: "Nick"
    data = interaction.read
    data["message"].must_equal "Hello Nick"
    interaction.close

    opened.called.must_equal true
    closed.called.must_equal true
  end
end