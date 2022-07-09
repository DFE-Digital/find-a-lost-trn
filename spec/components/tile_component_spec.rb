require "rails_helper"

RSpec.describe TileComponent, type: :component do
  subject { described_class.new(count: 3, label: "blind mice") }

  it "renders the count" do
    expect(rendered_result_text).to include("3")
  end

  it "renders the label" do
    expect(rendered_result_text).to include("blind mice")
  end

  describe "a tile with large number" do
    subject { described_class.new(count: 3000, label: "blind mice") }

    it "renders the count with a delimiter" do
      expect(rendered_result_text).to include("3,000")
    end
  end

  describe "a tile with percentage" do
    subject do
      described_class.new(count: "90%", label: "of all users succeeded")
    end

    it "renders the count with a delimiter" do
      expect(rendered_result_text).to include("90%")
    end
  end

  describe "a tile with an overridden colour" do
    subject do
      described_class.new(count: 3, label: "blind mice", colour: :blue)
    end

    it "applies the override CSS class" do
      expect(rendered_result_html).to include("app-card--blue")
    end
  end

  describe "a secondary tile" do
    subject do
      described_class.new(count: 3, label: "blind mice", size: :secondary)
    end

    it "has different (smaller) text" do
      expect(rendered_result_html).to include("app-card__secondary-count")
    end
  end

  def rendered_result_html
    render_inline(subject).to_html
  end

  def rendered_result_text
    render_inline(subject).text
  end
end
