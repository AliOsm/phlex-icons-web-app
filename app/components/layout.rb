# frozen_string_literal: true

class Components::Layout < Components::Base
  def initialize(title:)
    @title = title
  end

  def view_template
    doctype

    html(class: "light") do
      head do
        title { @title }

        meta(name: "viewport", content: "width=device-width,initial-scale=1")
        meta(name: "apple-mobile-web-app-capable", content: "yes")
        meta(name: "view-transition", content: "same-origin")
        csrf_meta_tags
        csp_meta_tag

        link(rel: "manifest", href: "/manifest.json")
        link(rel: "icon", href: "/icon.png", type: "image/png")
        link(rel: "icon", href: "/icon.svg", type: "image/svg+xml")
        link(rel: "apple-touch-icon", href: "/icon.png")
        stylesheet_link_tag "application", "data-turbo-track": "reload"
        javascript_include_tag "application", "data-turbo-track": "reload", type: "module"

        style(id: "search-style")
      end

      body { yield }
    end
  end
end
