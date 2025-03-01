# frozen_string_literal: true

require "uri"

class Enrichment
  def self.enrich(element:, result:, layout:, layout_field:, opts: {})
    layout_field = layout_field.to_s

    if layout[:type] == :image
      result[layout_field] = enrich_image(element, opts[:image_cache])

    elsif layout[:type] == :url && result[layout_field]
      result[layout_field] = enrich_link(result[layout_field], opts[:base_path])
    end

    result
  end

  def self.enrich_image(img_element, image_cache)
    # Try different attributes where the real image might be stored
    src = img_element["data-src"] ||
          img_element["data-deferred-src"] ||
          img_element["data-original"] ||
          img_element["src"]

    # If the src looks like a placeholder (very short or contains 'data:image/gif')
    if !image_cache.nil? && (src.include?("data:image/gif") || src.length < 100)
      src = image_cache[img_element["id"]]
    end

    # Return whatever we found, even if it's just the placeholder
    src
  end

  def self.enrich_link(path, base_path)
    begin
      uri = URI.parse(path)

      # Check if the URL is already absolute (has a scheme like http or https)
      if uri.scheme.nil? || uri.host.nil?
        # It's a relative URL, so join it with the base URL
        URI.join(base_path, path).to_s
      else
        # It's already an absolute URL
        path
      end
    rescue URI::InvalidURIError
      nil
    end
  end
end
