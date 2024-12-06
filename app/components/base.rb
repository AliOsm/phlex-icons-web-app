# frozen_string_literal: true

class Components::Base < Phlex::HTML
  include Components

  # Include any helpers you want to be available across all components
  include Phlex::Rails::Helpers::CSPMetaTag
  include Phlex::Rails::Helpers::CSRFMetaTags
  include Phlex::Rails::Helpers::JavascriptIncludeTag
  include Phlex::Rails::Helpers::NumberWithDelimiter
  include Phlex::Rails::Helpers::Routes
  include Phlex::Rails::Helpers::StylesheetLinkTag
  include Phlex::Rails::Helpers::T

  include Components
  include RubyUI
  include PhlexIcons

  register_value_helper :params

  if Rails.env.development?
    def before_template
      comment { "Before #{self.class.name}" }
      super
    end
  end
end
