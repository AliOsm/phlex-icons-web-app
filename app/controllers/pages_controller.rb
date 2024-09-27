class PagesController < ApplicationController
  include Phlex::Rails::Streaming

  def home
    stream Views::Pages::Home.new
  end

  def icon_sheet
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.update("icon-sheet", Views::Pages::IconSheet.new) }
    end
  end
end
