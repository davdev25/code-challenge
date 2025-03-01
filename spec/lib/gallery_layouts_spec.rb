# frozen_string_literal: true

require "rspec"
require "./lib/gallery_layouts"

RSpec.describe GalleryLayouts do
  describe ".lookup" do
    subject(:lookup) { described_class.lookup(category) }

    context "when category is defined" do
      let(:category) { "kc:/visual_art/visual_artist:works" }

      it "returns category" do
        expect(lookup[:collection_root]).to eq("artworks")
      end
    end

    context "when category is not found" do
      let(:category) { "unknown category" }

      it "returns default" do
        expect(lookup[:collection_root]).to eq("items")
      end
    end
  end
end
