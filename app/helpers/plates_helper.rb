require 'json'
module PlatesHelper

  extend self
  def generate_well_cell(well)
    unless well.sample.nil?
      if(Sample.states[well.sample.state] == Sample.states[:retest])
        tag.td class: 'cell rejected-cell'do
          link_to"#{well.row}#{well.column}", well.sample
        end
      elsif( well.sample.control?)
        tag.td class: 'cell control-cell'do
          link_to"#{well.row}#{well.column}", well.sample
        end
      else
        tag.td class: 'cell marked-cell' do
          link_to"#{well.row}#{well.column}", well.sample
        end
      end
    else
      tag.td do
        "#{well.row}#{well.column}"
      end
    end
  end

  def get_plate_badge(status)
    case Plate.states.to_hash[status]
    when Plate.states[:preparing]
      return tag.span class: 'badge badge-pill badge-primary' do
        status
      end
    when Plate.states[:prepared]
      return tag.span class: 'badge badge-pill badge-secondary' do
        status
      end
    when Plate.states[:testing]
      return tag.span class: 'badge badge-pill badge-info' do
        status
      end
    when Plate.states[:complete]
      return tag.span class: 'badge badge-pill badge-success' do
        status
      end
    when Plate.states[:analysed]
      return tag.span class: 'badge badge-pill badge-success' do
        status
      end
    end
  end

  def generate_test_cell(well)
    if test_result_exists?(well)
      if(Sample.states[well.sample.state] == Sample.states[:retest])
        tag.td class: 'cell rejected-cell'do
          link_to well.sample do
            get_result_icon(well.test_result)
          end
        end
      elsif( well.sample.control?)
        tag.td class: 'cell control-cell' do
          link_to well.sample do
            get_result_icon(well.test_result)
          end
        end
      else
        tag.td class: 'cell marked-cell' do
          link_to well.sample do
            get_result_icon(well.test_result)
          end
        end
      end
    else
      tag.td do
        "#{well.row}#{well.column}"
      end
    end
  end


  def test_result_exists?(well)
    !well.test_result.nil? && !well.sample.nil?
  end

  
  def get_result_icon(result)
    case TestResult.states.to_hash[result.state]
    when TestResult.states[:positive]
      fa_icon "plus-circle", class: 'fa-fw'
    when TestResult.states[:lowpositive]
      fa_icon "plus", class: 'fa-fw'
    when TestResult.states[:negative]
      fa_icon "minus", class: 'fa-fw'
    when TestResult.states[:inhibit]
      fa_icon "question-circle", class: 'fa-fw'
    end
  end

  def westgard_link(plate)
    return nil unless plate
    filename = "tests-#{plate.uid}.json"
    url = ENV.fetch("WESTGARD_STORAGE") { 'https://opencellstorage.blob.core.windows.net/results/' }
    uri = URI.join(url, filename)
      begin
        result = Net::HTTP.get_response(uri)
        if result.code == "200"
          b = JSON.parse(result.body)
          list_elements = b.map do |tst|
            content_tag(:span, title: tst['name']) do
              if tst['success']
                fa_icon "check", class: 'fa-fw'
              else
                fa_icon "cross", class: 'fa-fw'
              end
            end
          end
          c = content_tag(:span) do
            list_elements.each do |test|
              concat test
            end
          end
          puts c
          return link_to uri.to_s do 
                c
            end 
        else
          return p "No Results"
        end
    rescue => exception
      return p "Fetch Error"
    end
  end

end
