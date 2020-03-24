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


  def free_cells_before(col, row, well)
    well_col = well[:column]
    return (well_col - col) > 1 || row < well[:row]
  end

  def generate_preceding_cells(last_col, last_row, well)
    well_col = well[:column]
    new_cols_needed = well_col - last_col
    mapped =  (last_col..(well_col - 1)).map do |cell|
      tag.p cell
    end
    return mapped
  end
end
