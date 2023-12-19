require 'date'
require 'combine_pdf'

year = 2024
start_date = Date.new(year, 1, 1)
end_date = Date.new(year, 12, 31)

Dir.mkdir('output') unless Dir.exist?('output')

pdf = CombinePDF.new

start_date.step(end_date, 7) do |date|
  file_name = "output/planner_#{date.strftime('%Y_%m_%d')}.pdf"
  `./planner.rb #{date} #{file_name}`
  if File.exist?(file_name)
    week_pdf = CombinePDF.load(file_name)
    pdf << week_pdf
  else
    puts "File #{file_name} does not exist"
  end
end

pdf.save "output/yearly_planner_#{year}.pdf"
