# frozen_string_literal: true

require "rspec"
require "./lib/knowledge_graph"

RSpec.describe KnowledgeGraph do
  describe "#call" do
    subject(:knowledge_graph) { described_class.new(html_content, "https://www.google.com/").call }

    let(:html_content) { File.read("files/van-gogh-paintings.html") }
    let(:expected_data) { JSON.parse(File.read("files/expected-array.json")) }

    context "when category is found" do
      it "returns expected array" do
        expect(knowledge_graph).to eq(expected_data)
      end
    end

    context "when category is not found" do
      let(:html_content) {'
        <!DOCTYPE html>
          <html lang="en">
            <head>
              <meta charset="UTF-8">
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <title>Document</title>
            </head>
            <body></body>
        </html>
      '}

      it "raises an exception" do
        expect { knowledge_graph }.to raise_error(RuntimeError)
      end
    end
  end
end
