class PagesController < ApplicationController
  def login
  end

  def test_message
    render partial: "shared/message", formats: :turbo_stream, locals: { message: "This is a test Turbo Stream message!" }
  end
end
