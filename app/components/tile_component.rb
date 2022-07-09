class TileComponent < ViewComponent::Base
  attr_reader :count, :label, :colour

  def initialize(count:, label:, colour: :default, size: :regular)
    super
    @count = count
    @label = label
    @colour = colour
    @size = size
  end

  def count_class
    @size == :regular ? "app-card__count" : "app-card__secondary-count"
  end
end
