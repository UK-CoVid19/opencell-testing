module PlatesHelper

  def sample_exists?(well)
    return !well.sample.nil?
  end


  def generate_well_cell(well)
    if sample_exists?(well)
      if(Sample.states[well.sample.state] == Sample.states[:rejected])
        tag.td class: 'rejected-cell'do
          link_to"#{well.row}#{well.column}", well.sample
        end
      else
        tag.td class: 'marked-cell' do
          link_to"#{well.row}#{well.column}", well.sample
        end
      end
    else
      tag.td do
        "#{well.row}#{well.column}"
      end
    end
  end


  def generate_test_cell(well)
    if test_result_exists?(well)
      if(Sample.states[well.sample.state] == Sample.states[:rejected])
        tag.td class: 'rejected-cell'do
          link_to"#{well.row}#{well.column}", well.sample
        end
      else
        tag.td class: 'marked-cell' do
          tag.b "#{well.test_result.value}"
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
