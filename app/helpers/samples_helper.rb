module SamplesHelper

  def retest_selected(query_sample, retest_samples)
    if query_sample.nil?
      if retest_samples.present? && retest_samples.any?
        retest_samples.first.id
      else
        nil
      end
    else
      query_sample.id
    end
  end

  def get_badge(status)
    case Sample.states.to_hash[status]
    when Sample.states[:requested], Sample.states[:dispatched],
        Sample.states[:received],
        Sample.states[:preparing],
        Sample.states[:prepared],
        Sample.states[:tested],
        Sample.states[:analysed]
        return tag.span class: 'badge badge-pill badge-primary' do
          status.capitalize
        end
    when Sample.states[:communicated],
        Sample.states[:commcomplete]
      return tag.span class: 'badge badge-pill badge-success' do
        status.capitalize
      end
    when Sample.states[:rejected], Sample.states[:commfailed]
      return tag.span class: 'badge badge-pill badge-danger' do
        status.capitalize
      end
    when Sample.states[:retest]
      return tag.span class: 'badge badge-pill badge-warning' do
        status.capitalize
      end
    else
      puts "plate status is #{status}"
      raise
    end
  end

  def get_control_badge(control)
    if control
      tag.span class: 'badge badge-pill badge-warning' do
        "Control"
      end
    else
      tag.span class: 'badge badge-pill badge-primary' do
        "Sample"
      end
    end
  end

  def get_sample_bar(sample)
    status = sample.state
    case Sample.states.to_hash[status]
    when Sample.states[:requested]
      return 10
    when Sample.states[:dispatched]
      return 20
    when Sample.states[:received]
      return 30
    when Sample.states[:preparing],
        Sample.states[:prepared],
        Sample.states[:tested]
      return 50
    when Sample.states[:analysed]
      return 75
    when Sample.states[:communicated], Sample.states[:commcomplete]
      return 100
    when Sample.states[:rejected], Sample.states[:commfailed], Sample.states[:retest]
      return 100
    else
      raise
    end
  end


  def get_elapsed_hours(sample)
    rerun = sample.rerun_for?
    if rerun
      t = sample.rerun_for.source_sample.created_at
    else
      t = sample.created_at
    end
    ((Time.now - t) / 3600).round
  end

  def control?(row, col)
    PlateHelper.control_positions.include?(row: row, col: col)
  end

  def negative_control?(row, col)
    PlateHelper.negative_extraction_controls.include?(row: row, col: col)
  end

  def positive_control?(row, col)
    PlateHelper.positive_control_positions.include?(row: row, col: col)
  end

  def auto_control?(row, col)
    PlateHelper.auto_control_positions.include?(row: row, col: col)
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


  def get_focus_index(well)
    # the index is the letter index plus the number index times the letter index
    row_index = PlateHelper.rows.find_index(well.row)
    raise "row out of range #{well.row}" unless row_index

    col_index = PlateHelper.columns.find_index(well.column)
    raise "column out of range #{well.column}" unless col_index
    
    rows_a = PlateHelper.rows.to_a
    (row_index + 1) + (rows_a.size * col_index)
  end
end
