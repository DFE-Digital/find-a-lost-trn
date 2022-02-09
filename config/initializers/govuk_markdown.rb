# frozen_string_literal: true

class MarkdownTemplate
  def self.call(template, source)
    compiled = GovukMarkdown.render(source)
    erb_handler.call(template, compiled)
  end

  def self.erb_handler
    ActionView::Template.registered_template_handler(:erb)
  end
end

ActionView::Template.register_template_handler :md, MarkdownTemplate
