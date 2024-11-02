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
  begin_new_page pdf, :left

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
puts "#{options[:date_source]} Will save to #{FILE_NAME}"
sunday = options[:date]

pdf = init_pdf

options[:weeks].times do |week|
  begin_new_page(pdf, :right) unless week.zero?

  monday = sunday.next_day(1)
  next_sunday = sunday.next_day(7)
  puts "Generating one-on-one forms for #{date_range(monday, next_sunday)}"

  names_and_dates = one_on_ones_for(sunday)
    .each_with_index
    .reject { |names, _| names.nil? }
    .flat_map { |names, wday| names.map {|name| [name, sunday.next_day(wday)] } }

  # Show who we're meeting each day
  names_and_dates
    .group_by { |name, date| date }
    .transform_values{ |day| day.map{ |name, _| name }.sort }
    .map { |date, names| puts "#{I18n.l(date, format: :long)}\n- #{names.join("\n- ")}" }

  hole_punches pdf

  names_and_dates
    .sort_by { |name, date| "#{name}#{date.iso8601}" } # Sort by name or date, as you like
    .each_with_index { |name_and_date, index|
      begin_new_page(pdf, :right) unless index.zero?
      one_on_one_page(pdf, *name_and_date)
    }

  sunday = sunday.next_day(7)
end

pdf.render_file FILE_NAME
