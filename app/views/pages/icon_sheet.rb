# frozen_string_literal: true

class Views::Pages::IconSheet < Views::Base
  def view_template
    RBUI::Sheet() do
      RBUI::SheetTrigger(data: { controller: "click" }) { }

      RBUI::SheetContent(class: "w-[300px]") do
        RBUI::SheetHeader(class: "text-left") do
          RBUI::SheetTitle() { params[:icon] }
          RBUI::SheetDescription(class: "gap-y-2") do
            plain params[:pack]
          end

          RBUI::Link(
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

        RBUI::SheetMiddle(class: "space-y-4") do
          sheet_body
        end

        RBUI::SheetFooter() do
          RBUI::Button(variant: :outline, data: { action: "click->rbui--sheet-content#close" }) { t("pages.icon_sheet.close") }
        end
      end
    end
  end

  private

  def icon_source_code_url
    "https://github.com/AliOsm/phlex-icons/blob/main/lib/phlex/icons/#{params[:pack].split('::').last.downcase}/#{params[:icon].underscore}.rb"
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
        RBUI::TypographySmall() { t("pages.icon_sheet.icon") }
        whitespace
        RBUI::TypographySmall() { "↓" }

        icon
      end

      with_phlex_kit_block
      without_phlex_kit_block
    end
  end

  def variants_icon
    params[:pack].constantize::VARIANTS.each do |variant|
      begin
        div(class: "space-y-2") do
          div do
            RBUI::TypographySmall() do
              plain t("pages.icon_sheet.icon")
              whitespace
              plain "("
              plain t("pages.icon_sheet.variant")
              plain ":"
            end
            whitespace
            RBUI::TypographyInlineCode() do
              plain ":"
              plain variant.to_s
            end
            plain ")"
            whitespace
            RBUI::TypographySmall() { "↓" }

            icon(variant:)
          end

          with_phlex_kit_block(variant: variant)
          without_phlex_kit_block(variant: variant)
        end
      rescue NotImplementedError
        RBUI::TypographyMuted() { "Variant not implemented" }
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
      RBUI::TypographySmall() { t("pages.icon_sheet.with") }
      whitespace
      RBUI::TypographyInlineCode() { t("pages.icon_sheet.phlex_kit") }
      whitespace
      RBUI::TypographySmall() { "↓" }

      div(class: "w-full mt-1") do
        if variant
          RBUI::Codeblock("#{params[:pack].split("::").last}::#{params[:icon]}(variant: :#{variant})", syntax: :ruby)
        else
          RBUI::Codeblock("#{params[:pack].split("::").last}::#{params[:icon]}()", syntax: :ruby)
        end
      end
    end
  end

  def without_phlex_kit_block(variant: nil)
    div do
      RBUI::TypographySmall() { t("pages.icon_sheet.without") }
      whitespace
      RBUI::TypographyInlineCode() { t("pages.icon_sheet.phlex_kit") }
      whitespace
      RBUI::TypographySmall() do
        plain "("
        plain t("pages.icon_sheet.eg_erb")
        plain ")"
      end
      whitespace
      RBUI::TypographySmall() { "↓" }

      div(class: "w-full mt-1") do
        if variant
          RBUI::Codeblock("render #{params[:pack]}::#{params[:icon]}.new(variant: :#{variant})", syntax: :ruby)
        else
          RBUI::Codeblock("render #{params[:pack]}::#{params[:icon]}.new", syntax: :ruby)
        end
      end
    end
  end
end
