module PlatesHelper

  def generate_well_cell(well)
    unless well.sample.nil?
      if(Sample.states[well.sample.state] == Sample.states[:rejected])
        tag.td class: 'cell rejected-cell'do
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
      if(Sample.states[well.sample.state] == Sample.states[:rejected])
        tag.td class: 'cell rejected-cell'do
          link_to"#{well.test_result.value}", well.sample
        end
      else
        tag.td class: 'cell marked-cell' do
          link_to"#{well.test_result.value}", well.sample
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


end
