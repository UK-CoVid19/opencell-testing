module PlatesHelper

  def sample_exists?(well)
    return well.samples && well.samples.any?
  end


end
