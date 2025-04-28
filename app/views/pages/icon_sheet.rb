# frozen_string_literal: true

class Views::Pages::IconSheet < Views::Base
  def view_template
    Sheet() do
      SheetTrigger(data: { controller: "click" }) { }

      SheetContent(class: "w-[300px] overflow-scroll") do
        SheetHeader(class: "text-left") do
          SheetTitle() { params[:icon] }
          SheetDescription(class: "gap-y-2") do
            plain params[:pack]
          end

          Link(
            href: icon_source_code_url,
            variant: :outline,
            size: :sm,
            class: "flex items-center gap-1",
            target: :_blank
          ) do
            plain "Source code"

            Lucide::ExternalLink(class: "size-4")
          end
        end

        SheetMiddle(class: "space-y-4") do
          sheet_body
        end

        SheetFooter() do
          Button(variant: :outline, class: "w-full", data: { action: "click->ruby-ui--sheet-content#close" }) { t("pages.icon_sheet.close") }
        end
      end
    end
  end

  private

  def icon_source_code_url
    "https://github.com/AliOsm/phlex-icons/blob/main/lib/phlex-icons/#{params[:pack].split('::').last.downcase}/#{params[:icon].underscore}.rb"
  end

  def sheet_body
    if params[:pack].constantize::VARIANTS.nil?
      no_variants_icon
    else
      variants_icon
    end
  end

  def no_variants_icon
    div(class: "space-y-2") do
      div do
        Text(size: "sm") do
          plain t("pages.icon_sheet.icon")
          whitespace
          plain "↓"
        end

        icon
      end

      with_phlex_kit_block
      without_phlex_kit_block
      plain_phlex_block
      plain_svg_block
    end
  end

  def variants_icon
    params[:pack].constantize::VARIANTS.each do |variant|
      begin
        div(class: "space-y-2") do
          div do
            Text(size: "sm") do
              plain t("pages.icon_sheet.icon")
              whitespace
              plain "("
              plain t("pages.icon_sheet.variant")
              plain ":"
              whitespace

              InlineCode() do
                plain ":"
                plain variant.to_s
              end

              plain ")"
              whitespace
              plain "↓"
            end

            icon(variant:)
          end

          with_phlex_kit_block(variant:)
          without_phlex_kit_block(variant:)
          plain_phlex_block(variant:)
          plain_svg_block(variant:)
        end
      rescue NotImplementedError
        Text(size: "sm", weight: "muted") { "Variant not implemented" }
      end
    end
  end

  def icon(variant: nil)
    if variant
      render params[:pack].constantize.const_get(params[:icon]).new(variant: variant, class: "size-10")
    else
      render params[:pack].constantize.const_get(params[:icon]).new(class: "size-10")
    end
  end

  def with_phlex_kit_block(variant: nil)
    div do
      Text(size: "sm") do
        plain t("pages.icon_sheet.with")
        whitespace
        InlineCode() { t("pages.icon_sheet.phlex_kit") }
        whitespace
        plain "↓"
      end

      div(class: "w-full mt-1") do
        if variant
          Codeblock("#{params[:pack].split("::").last}::#{params[:icon]}(variant: :#{variant})", syntax: :ruby)
        else
          Codeblock("#{params[:pack].split("::").last}::#{params[:icon]}()", syntax: :ruby)
        end
      end
    end
  end

  def without_phlex_kit_block(variant: nil)
    div do
      Text(size: "sm") do
        plain t("pages.icon_sheet.without")
        whitespace
        InlineCode() { t("pages.icon_sheet.phlex_kit") }
        whitespace
        plain "("
        plain t("pages.icon_sheet.eg_erb")
        plain ")"
        whitespace
        plain "↓"
      end

      div(class: "w-full mt-1") do
        if variant
          Codeblock("render #{params[:pack]}::#{params[:icon]}.new(variant: :#{variant})", syntax: :ruby)
        else
          Codeblock("render #{params[:pack]}::#{params[:icon]}.new", syntax: :ruby)
        end
      end
    end
  end

  def plain_phlex_block(variant: nil)
    div do
      Text(size: "sm") do
        plain t("pages.icon_sheet.plain_phlex")
        whitespace
        plain "↓"
      end

      div(class: "w-full mt-1") do
        if variant
          source = params[:pack].constantize.const_get(params[:icon]).new.method(variant).source
          source = source.sub(variant.to_s, "view_template")
          source = source.gsub(/^\s{6}/, "")

          Codeblock(source, syntax: :ruby)
        else
          source = params[:pack].constantize.const_get(params[:icon]).new.method(:view_template).source
          source = source.gsub(/^\s{6}/, "")

          Codeblock(source, syntax: :ruby)
        end
      end
    end
  end

  def plain_svg_block(variant: nil)
    div do
      Text(size: "sm") do
        plain t("pages.icon_sheet.plain_svg")
        whitespace
        plain "↓"
      end

      div(class: "w-full mt-1") do
        if variant
          Codeblock(Nokogiri::XML(capture { render params[:pack].constantize.const_get(params[:icon]).new(variant:, class: "") }).to_xhtml, syntax: :html)
        else
          Codeblock(Nokogiri::XML(capture { render params[:pack].constantize.const_get(params[:icon]).new(class: "") }).to_xhtml, syntax: :html)
        end
      end
    end
  end
end
