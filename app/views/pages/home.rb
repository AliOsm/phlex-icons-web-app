# frozen_string_literal: true

class Views::Pages::Home < Views::Base
  ICON_PACKS = {
    Bootstrap => { bg_count: 500, link: "https://icons.getbootstrap.com" },
    Flag => { bg_count: 50, link: "https://flagicons.lipis.dev" },
    Hero => { bg_count: 250, link: "https://heroicons.com" },
    Lucide => { bg_count: 500, link: "https://lucide.dev/icons" },
    Radix => { bg_count: 250, link: "https://icons.radix-ui.com" },
    Remix => { bg_count: 1000, link: "https://remixicon.com" },
    Tabler => { bg_count: 1000, link: "https://tabler-icons.io" }
  }

  CONSTANTS_TO_EXCLUDE_FROM_BACKGROUND = [ :Configuration, :Base, :VERSION, :VARIANTS, :Il, :CrossFill, :CrossLine, :Cross, :CrossOff ]
  CONSTANTS_TO_EXCLUDE_FROM_SEARCH = [ :Configuration, :Base, :VERSION, :VARIANTS ]

  def view_template
    Layout(title: t("pages.home.title")) do
      div(id: "icon-sheet")

      header
      flush
      available_icon_packs
      flush
      discover_all_icon_packs
    end
  end

  private

  def header
    div(class: "relative h-screen overflow-hidden") do
      icons_background
      header_card
    end
  end

  def icons_background
    div(class: "grid grid-cols-12 sm:grid-cols-24 lg:grid-cols-48 divide-x divide-y opacity-50") do
      icons_to_render.shuffle.each { |icon| div { render icon } }
    end
  end

  def header_card
    Card(class: "absolute top-1/2 left-0 sm:left-1/2 transform sm:-translate-x-1/2 -translate-y-1/2 rounded-none sm:rounded-xl p-8 pt-0") do
      div(class: "flex flex-col justify-center text-center w-full") do
        img(src: "/phlex-icons.png")

        Heading(level: 1, class: "mb-4") { t("pages.home.title") }

        Link(href: "https://github.com/AliOsm/phlex-icons", variant: :outline, class: "gap-2", target: :_blank) do
          Bootstrap::Github(class: "size-4")
          plain t("pages.home.view_on_github")
        end
      end
    end
  end

  def icons_to_render
    ICON_PACKS.flat_map do |pack, info|
      pack.constants
          .reject { |const| CONSTANTS_TO_EXCLUDE_FROM_BACKGROUND.include?(const) }
          .sample(info[:bg_count])
          .map { |icon| pack.const_get(icon).new(class: "p-0.5 transition duration-100 hover:scale-[1.25]") }
    end
  end

  def available_icon_packs
    div(class: "container max-w-6xl py-24 lg:py-32") do
      Heading(level: 2) { t("pages.home.available_icon_packs") }

      div(class: "grid grid-cols-2 sm:grid-cols-4 gap-4") do
        icon_pack_card(
          name: PhlexIcons.to_s,
          version: PhlexIcons::VERSION,
          count: ICON_PACKS.sum { |pack, _| pack.constants.count },
          link: "https://github.com/AliOsm/phlex-icons"
        )

        ICON_PACKS.each do |pack, info|
          icon_pack_card(name: pack.name.split("::").last, version: pack::VERSION, count: pack.constants.count, link: info[:link])
        end
      end
    end
  end

  def icon_pack_card(name:, version:, count:, link:)
    Card(class: "rounded-lg") do
      CardHeader(class: "flex flex-row items-top justify-between space-y-0 pb-2") do
        CardTitle(class: "text-md font-medium") do
          plain name
          whitespace
          Text(size: "2", class: "text-muted-foreground") { "v#{version}" }
        end

        Link(href: link, variant: :outline, icon: true, class: "size-7", target: :_blank) do
          Lucide::ExternalLink(class: "size-4")
        end
      end

      CardContent(class: "pb-5") do
        div(class: "text-2xl font-bold") { number_with_delimiter(count) }
      end
    end
  end

  def discover_all_icon_packs
    div(class: "container max-w-6xl pt-0 lg:pt-0 py-24 lg:py-32") do
      div(class: "mb-8") do
        Heading(level: 1, class: "text-center mb-2") { t("pages.home.discover_all_icon_packs") }

        Input(
          type: "search",
          class: "w-full",
          placeholder: t("pages.home.search_available_icons"),
          data: {
            controller: "search",
            action: "input->search#search"
          }
        )
      end

      flush

      div(class: "space-y-8") do
        ICON_PACKS.each do |pack, _|
          icon_pack_block(pack)
          flush
        end
      end
    end
  end

  def icon_pack_block(pack)
    div do
      icon_pack_block_header(pack)
      icon_pack_block_icons(pack)
    end
  end

  def icon_pack_block_header(pack)
    Heading(level: 2, class: "pb-2 mb-4") do
      plain pack.name.split("::").last

      Text(size: "2", class: "text-muted-foreground") { number_with_delimiter(pack.constants.count) }

      div(class: "flex flex-row items-center space-x-2") do
        unless pack::VARIANTS.nil?
          whitespace
          Text(size: "2", class: "text-muted-foreground") { "#{t("pages.home.variants")}:" }
          whitespace

          pack::VARIANTS.each do |variant|
            InlineCode() do
              plain ":"
              plain variant.to_s
            end
          end
        end
      end
    end
  end

  def icon_pack_block_icons(pack)
    div(class: "grid grid-cols-8 sm:grid-cols-24 gap-4") do
      (pack.constants - CONSTANTS_TO_EXCLUDE_FROM_SEARCH).sort.each do |icon|
        a(href: icon_sheet_path(icon: icon, pack: pack.name), class: "searchable", data: { turbo_stream: true, index: icon.to_s.underscore.gsub("_", " ") }) do
          render pack.const_get(icon).new(class: "cursor-pointer")
        end
      end
    end
  end
end
