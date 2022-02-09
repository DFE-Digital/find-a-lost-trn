# frozen_string_literal: true

module ApplicationHelper
  # TODO: Upstream this behaviour into govuk-wizardry so we don't need this.
  def turbo_frame_tag(id, &block)
    tag.div(id: id, &block)
  end
end
