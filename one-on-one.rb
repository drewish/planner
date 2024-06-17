#!/usr/bin/env ruby

require_relative './shared'
FILE_NAME = "one-on-one_forms.pdf"


def sections pdf, first_row, last_row, headings
  (first_row..last_row).each do |row|
    pdf.grid([row, 0],[row, 3]).bounding_box do
      if headings[row]
        pdf.text headings[row], inline_format: true, valign: :bottom
      else
        pdf.stroke_line pdf.bounds.bottom_left, pdf.bounds.bottom_right
      end
    end
  end
end


def one_on_one_page pdf, name, date
  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  total_row_count = header_row_count + body_row_count
  pdf.define_grid(columns: COLUMN_COUNT, rows: total_row_count, gutter: 0)
  # pdf.grid.show_all

  pdf.grid([0, 0],[1, 1]).bounding_box do
    pdf.text name, heading_format(align: :left)
  end
  pdf.grid([1, 0],[1, 1]).bounding_box do
    pdf.text I18n.l(date, format: :long), subheading_format(align: :left)
  end
  # grid([0, 2],[0, 3]).bounding_box do
  #   text "right heading", heading_format(align: :right)
  # end

  sections(pdf, 2, body_row_count, {
    2 => "#{I18n.t('personal_notes')} <color rgb='#{MEDIUM_COLOR}'>#{I18n.t('personal_notes_example')}</color>",
    5 => "#{I18n.t('their_update')} <color rgb='#{MEDIUM_COLOR}'>#{I18n.t('their_update_instructions')}</color>",
    15 => "#{I18n.t('my_update')} <color rgb='#{MEDIUM_COLOR}'>#{I18n.t('my_update_instructions')}</color>",
    24 => "#{I18n.t('future')} <color rgb='#{MEDIUM_COLOR}'>#{I18n.t('future_instructions')}</color>",
  })

  # Back of the page
  if (OOOS_SIDE_BY_SIDE)
    begin_new_page pdf, :right
  else
    begin_new_page pdf, :left
  end


  pdf.grid([0, 0],[1, 1]).bounding_box do
    pdf.text name, heading_format(align: :left)
  end
  pdf.grid([1, 0],[1, 1]).bounding_box do
    pdf.text I18n.l(date, format: :long), subheading_format(align: :left)
  end

  question_start = 25
  question_end = question_start + 4

  sections(pdf, 2, question_start - 1, {
    2 => I18n.t('additional_notes'),
    20 => I18n.t('feedback'),
  })

  pdf.grid([question_start, 0],[question_start, 3]).bounding_box do
    pdf.text I18n.t('questions_to_ask'), valign: :bottom, color: DARK_COLOR
  end
  pdf.grid([question_start + 1, 0],[question_end, 1]).bounding_box do
    pdf.text I18n.t('questions_left'), size: 10, color: MEDIUM_COLOR
  end
  pdf.grid([question_start + 1, 2],[question_end, 3]).bounding_box do
    pdf.text I18n.t('questions_right'), size: 10, color: MEDIUM_COLOR
  end
end


options = parse_options
init_i18n(options[:locale])
puts options[:date_source]
sunday = options[:date]

pdf = init_pdf

options[:weeks].times do |week|
  if (OOOS_SIDE_BY_SIDE)
    begin_new_page(pdf, :left) unless week.zero?
  else
    begin_new_page(pdf, :right) unless week.zero?
  end

  monday = sunday.next_day(1)
  next_sunday = sunday.next_day(7)
  puts "Generating one-on-one forms for #{date_range(monday, next_sunday)}"

#pdf = init_pdf
hole_punches pdf

# If you want to have your one on one pages laid out side by side,
# you need to add a blank or notes page in the beginning
## we add a notes page at the beginning to start on a left page
if OOOS_SIDE_BY_SIDE
  heading_left = I18n.t('notes_heading')
  notes_page pdf, heading_left
  begin_new_page pdf, :left
end

OOOS_BY_WDAY
  .each_with_index
  .reject { |names, _| names.nil? }
  .flat_map { |names, wday| names.map {|name| [name, sunday.next_day(wday)] } }
  .sort_by { |name, date| "#{name}#{date.iso8601}" } # Sort by name or date, as you like
  .each_with_index { |name_and_date, index|
    if OOOS_SIDE_BY_SIDE
      begin_new_page(pdf, :left) unless index.zero?
    else
      begin_new_page(pdf, :right) unless index.zero?
    end
    one_on_one_page(pdf, *name_and_date)
  }

  sunday = sunday.next_day(7)
end



# we add a notes page at the end to end on a left page, if in side by side mode
if OOOS_SIDE_BY_SIDE
  begin_new_page pdf, :left
  heading_left = I18n.t('notes_heading')
  notes_page pdf, heading_left
end


puts "Saving to #{FILE_NAME}"
pdf.render_file FILE_NAME
