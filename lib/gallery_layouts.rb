# frozen_string_literal: true

class GalleryLayouts
  LAYOUTS = {
    "kc:/visual_art/visual_artist:works" => {
      layout: {
        name: {
          path: ["a", "div", "div:nth-child(1)"],
          transform: -> (element) { element.text }
        },
        extensions: {
          path: ["a", "div", "div:nth-child(2)"],
          transform: -> (element) { element.text == "" ? nil : [element.text] }
        },
        image: {
          path: ["a", "img"],
          transform: -> (element) { element.send(:[], "src") },
          type: :image
        },
        link: {
          path: ["a"],
          transform: -> (element) { element.send(:[], "href") },
          type: :url
        }
      },
      collection_root: "artworks",
      leaf_target: :extensions,
      leaf_depth: 2
    }
  }

  DEFAULT_LAYOUT = {
    layout: {
      name: {
        path: ["a", "div", "div:nth-child(1)"],
        transform: -> (element) { element.text }
      },
      extensions: {
        path: ["a", "div", "div:nth-child(2)"],
        transform: -> (element) { element.text == "" ? nil : [element.text] }
      },
      image: {
        path: ["a", "img"],
        transform: -> (element) { element.send(:[], "src") },
        type: :image
      },
      link: {
        path: ["a"],
        transform: -> (element) { element.send(:[], "href") },
        type: :url
      }
    },
    collection_root: "items",
    leaf_target: :extensions,
    leaf_depth: 2
  }

  def self.lookup(type)
    LAYOUTS[type] || DEFAULT_LAYOUT
  end
end
