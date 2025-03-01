# frozen_string_literal: true

require "nokogiri"
require "json"
require_relative "./gallery_layouts"
require_relative "./enrichment"

class KnowledgeGraph
  attr_reader :html_content, :base_path

  def initialize(html_content, base_path)
    @doc       = Nokogiri::HTML(html_content)
    @base_path = base_path
  end

  def call
    { gallery_layout[:collection_root] => process }
  end

  private

    def doc
      @doc ||= Nokogiri::HTML(html_content)
    end

    def gallery_container
      return @gallery_container if defined?(@gallery_container)

      @gallery_container = doc.css('[data-attrid^="kc:/"]')[0]
      raise "Category not found" if @gallery_container.nil?

      @gallery_container
    end

    def gallery_layout
      @gallery_layout ||= GalleryLayouts.lookup(gallery_container["data-attrid"])
    end

    def image_cache
      return @image_cache if defined?(@image_cache)

      @image_cache = {}

      # Get all deferred images first
      deferred_images = doc.css('img[data-deferred="1"]')
      deferred_ids    = deferred_images.map { |img| img["id"] }

      # Process all scripts
      doc.css("script").each do |script|
        script_text = script.text

        # Skip scripts that definitely don't have image data
        next unless script_text.include?("data:image") && script_text.include?("base64")

        # Look for arrays that might contain image IDs
        potential_ids = script_text.scan(/\[\s*'([^']+)'(?:\s*,\s*'[^']+')*\s*\]/).flatten

        # Check if any of these IDs match our deferred images
        matching_ids = potential_ids & deferred_ids

        if matching_ids.any?
          # Found a script that references our images
          # Now extract the image data
          data_match = script_text.scan(/(data:image\/[^;]+;base64,[^"',]+)(?:\\x3d\\x3d)?/)&.flatten

          if data_match
            image_data = data_match[0]
            clean_data = image_data.gsub(/\\x3d/, '=').gsub(/\\\\/, '\\')

            # Associate this data with each matching image ID
            matching_ids.each do |id|
              image_cache[id] = clean_data
            end
          end
        end
      end

      # Build the final results
      results = {}
      deferred_images.each do |img|
        img_id = img["id"]
        if img_id && image_cache[img_id]
          results[img_id] = {
            alt: img["alt"],
            deferred_src: image_cache[img_id]
          }
        end
      end

      results
    end

    def process
      results = []

      # Find all leaf elements in the categories result container.
      leaf_target_path = gallery_layout.dig(:layout, @gallery_layout[:leaf_target], :path).join(" > ")
      leaf_elements    = gallery_container.css(leaf_target_path)
      depth            = gallery_layout[:leaf_depth]

      leaf_elements.each do |leaf_element|
        # Work backward to find the result item's container
        container = leaf_element
        depth.times do
          container = container.parent
        end

        result = {}

        gallery_layout[:layout].each do |key, value|
          path_from_parent = value[:path][1..-1].join(" > ")
          element          = path_from_parent == "" ? container : container.at_css(path_from_parent)
          value_to_store   = value[:transform].call(element)
          result[key.to_s] = value_to_store unless value_to_store.nil?

          result = Enrichment.enrich(
            element: element,
            result: result,
            layout_field: key,
            layout: value,
            opts: {
              image_cache: image_cache,
              base_path: base_path
            }
          )
        end

        results << result
      end

      results
    end
end
