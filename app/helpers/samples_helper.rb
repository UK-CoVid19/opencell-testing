module SamplesHelper

  def get_badge(status)
    case Sample.states.to_hash[status]
    when Sample.states[:requested], Sample.states[:dispatched],
        Sample.states[:received],
        Sample.states[:preparing],
        Sample.states[:prepared],
        Sample.states[:tested],
        Sample.states[:analysed],
        Sample.states[:communicated],
        Sample.states[:commcomplete]
      return tag.span class: 'badge badge-pill badge-primary' do
        status.capitalize
      end
    when Sample.states[:rejected], Sample.states[:commfailed]
      return tag.span class: 'badge badge-pill badge-danger' do
        status.capitalize
      end
    else
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
    when Sample.states[:rejected], Sample.states[:commfailed]
      return 100
    else
      raise
    end
  end

  def control?(row, col)
    PlateHelper.control_positions.include?(row: row, col: col)
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
end
