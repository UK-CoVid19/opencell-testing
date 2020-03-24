module PlatesHelper


  def well_exists?(plate, row, column)
    plate.wells.find_by(row: row, column: column.to_i)
  end


  def well_check(plate, row, column)
    if(well_exists?(plate, row, column))
      check_box_tag("wells[][id]", true, false)
    else
      check_box_tag("wells[][id]", true, false, disabled: 'disabled')
    end

  end
end
