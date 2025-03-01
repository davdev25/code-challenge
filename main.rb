# frozen_string_literal: true

require "./lib/knowledge_graph"
require "json"
require "pry"

FILES_DIR        = "./files".freeze
INPUT_FILE_NAMES = ["donatello-sculptures", "picaso-paintings", "van-gogh-paintings", "salvador-dali"]
BASE_URL         = "https://www.google.com/".freeze

INPUT_FILE_NAMES.each do |file_name|
  File.open(File.join(FILES_DIR, "#{file_name}.html")) do |input_file|
    result      = KnowledgeGraph.new(input_file, BASE_URL).call
    json_result = JSON.pretty_generate(result)

    File.open(File.join(FILES_DIR, "#{file_name}-output.json"), 'w') { |f| f.write(json_result) }
  end
end