# frozen_string_literal: true

class MarkdownTemplate
  def self.call(template, source)
    source ||= template.source

    # Rails >= 7.1 does not work with the Redcarpet markdown renderer.
    # There is an argument mismatch where a string is expected but an OutputBuffer is provided.
    # This is a workaround to convert the buffer to a string.
    erb_handler = ActionView::Template.registered_template_handler(:erb)
    erb_handler.call(template, source)
    compiled_source = ActionView::OutputBuffer.new( erb_handler.call( template, source ) )
    compiled_source << '.to_s'
    "GovukMarkdown.render(begin;#{compiled_source};end).html_safe"
  end
end

ActionView::Template.register_template_handler :md, MarkdownTemplate
