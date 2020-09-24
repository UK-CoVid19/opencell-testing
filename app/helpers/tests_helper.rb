module TestsHelper


  def create_test_cell_contents(form, test, rw)
    if test.test_results.map(&:well_id).include? rw.id
      flds = form.fields_for :test_results, test.test_results.select{|i| i.well_id == rw.id} do |result_builder|
        result_builder.hidden_field :well_id
        result_builder.hidden_field :id
        result_builder.text_field :value, class: 'form-control'
      end
      return flds
    else
      "Nothing here"
    end
  end

  def retest_disabled?(well)
    if well.sample.retest?
      return true
    end

    if well.sample.rerun_for?
      return true
    end
    false
  end
end
