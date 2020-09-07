module TestResultsModule
  require "json-schema"

  SCHEMA = {
    "type" => "array",
    "items" => [
    {
      "type": "object",
      "properties" => {
        "row" => {
          "type" => "string"
        },
        "col": {
          "type" => "integer"
        },
        "result" => {
          "type" => "string"
        }
      },
      "required": [
        "row",
        "col",
        "result"
      ]
    }
    ]
  }

  def self.validate_results(results)
    JSON::Validator.validate(SCHEMA, results, strict: true)
  end
end