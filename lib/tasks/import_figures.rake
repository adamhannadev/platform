# Example: lib/tasks/import_figures.rake
require 'roo'

namespace :import do
  desc "Import figures from Excel"
  task figures: :environment do
    xlsx = Roo::Spreadsheet.open('br_smooth.xlsx')
    puts "The sheets are: #{xlsx.sheets}"
    xlsx.each_with_pagename do |name, sheet|
      puts "#{name}"
        xlsx.each_row_streaming(offset: 0) do |row|
        Figure.create!(
        name: row[2]&.cell_value,
        dance: name,
        number: row[1]&.cell_value,
        bars: row[3]&.cell_value,
        components: row[4]&.cell_value,
        core: row[0]&.cell_value,
        level: row[5]&.cell_value
        )
      end
    end
      
  end
end