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
        "column": {
          "type" => "integer"
        },
        "state" => {
          "type" => "string"
        }
      },
      "required": [
        "row",
        "column",
        "state"
      ]
    }
    ]
  }

  def self.validate_results(results)
    JSON::Validator.validate(SCHEMA, results, strict: true)
  end
end