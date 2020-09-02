# frozen_string_literal: true
class AntivirusValidator < ActiveModel::Validator
  def validate(record)
    return unless record.attachment_changes[options[:attribute_name].to_s]

    path = record.attachment_changes[options[:attribute_name].to_s].attachable.tempfile.path

    if Clamby.virus?(path)
      record.errors.add(options[:attribute_name], 'infected_file')
    end
  end
end
