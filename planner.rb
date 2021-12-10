#!/usr/bin/env ruby

require "prawn"
require 'pry'
require 'date'

WEEKS = 2
HOUR_LABELS = [nil, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, nil, nil]
HOUR_COUNT = HOUR_LABELS.length
COLUMN_COUNT = 4
MEDIUM_COLOR = '888888'
DARK_COLOR   = '000000'
OSX_FONT_PATH = "/System/Library/Fonts/Supplemental/Futura.ttc"
FILE_NAME = "time_block_pages.pdf"
# Order is top, right, bottom, left
LEFT_PAGE_MARGINS = [36, 72, 36, 36]
RIGHT_PAGE_MARGINS = [36, 36, 36, 72]


# From https://stackoverflow.com/a/24753003/203673
#
# Calculates the number of business days in range (start_date, end_date]
#
# @param start_date [Date]
# @param end_date [Date]
#
# @return [Fixnum]
def business_days_between(start_date, end_date)
  days_between = (end_date - start_date).to_i
  return 0 unless days_between > 0

  # Assuming we need to calculate days from 9th to 25th, 10-23 are covered
  # by whole weeks, and 24-25 are extra days.
  #
  # Su Mo Tu We Th Fr Sa    # Su Mo Tu We Th Fr Sa
  #        1  2  3  4  5    #        1  2  3  4  5
  #  6  7  8  9 10 11 12    #  6  7  8  9 ww ww ww
  # 13 14 15 16 17 18 19    # ww ww ww ww ww ww ww
  # 20 21 22 23 24 25 26    # ww ww ww ww ed ed 26
  # 27 28 29 30 31          # 27 28 29 30 31
  whole_weeks, extra_days = days_between.divmod(7)

  unless extra_days.zero?
    # Extra days start from the week day next to start_day,
    # and end on end_date's week date. The position of the
    # start date in a week can be either before (the left calendar)
    # or after (the right one) the end date.
    #
    # Su Mo Tu We Th Fr Sa    # Su Mo Tu We Th Fr Sa
    #        1  2  3  4  5    #        1  2  3  4  5
    #  6  7  8  9 10 11 12    #  6  7  8  9 10 11 12
    # ## ## ## ## 17 18 19    # 13 14 15 16 ## ## ##
    # 20 21 22 23 24 25 26    # ## 21 22 23 24 25 26
    # 27 28 29 30 31          # 27 28 29 30 31
    #
    # If some of the extra_days fall on a weekend, they need to be subtracted.
    # In the first case only corner days can be days off,
    # and in the second case there are indeed two such days.
    tomorrow = start_date.next_day(1)
    extra_days -= if tomorrow.wday <= end_date.wday
                    [tomorrow.sunday?, end_date.saturday?].count(true)
                  else
                    2
                  end
  end

  (whole_weeks * 5) + extra_days
end

def business_days_left_in_year(date)
  business_days_between(date, Date.new(date.year, 12, 31))
end

def quarter(date)
  (date.month / 3.0).ceil
end

def draw_checkbox checkbox_size, checkbox_padding
  dash 1, phase: 0.5
  rectangle [bounds.top_left[0] + checkbox_padding, bounds.top_left[1] - checkbox_padding], checkbox_size, checkbox_size
  stroke
  undash
end

# * * *

def week_ahead_page first_day, last_day
  # We don't start our own page since we don't know if this is the first week or one
  # of several weeks in a file.
  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  first_column = 0
  last_column = COLUMN_COUNT - 1
  last_row = header_row_count + body_row_count - 1

  define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)
  # grid.show_all

  # Header
  grid([0, first_column],[0, last_column]).bounding_box do
    text "The Week Ahead", inline_format: true, size: 20, align: :left
  end
  grid([0, 3],[0, last_column]).bounding_box do
    text first_day.strftime("Week %W"), inline_format: true, size: 20, align: :right
  end
  grid([1, first_column],[1, last_column]).bounding_box do
    range = "#{first_day.strftime('%A, %B %-d')} — #{last_day.strftime('%A, %B %-d, %Y')}"
    text range, color: MEDIUM_COLOR, align: :left
  end

  # Horizontal lines
  (2..last_row).each do |row|
    grid([row, first_column], [row, last_column]).bounding_box do
      stroke_line bounds.bottom_left, bounds.bottom_right
    end
  end
end

def task_page date
  start_new_page(margin: LEFT_PAGE_MARGINS)

  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  last_row = header_row_count + body_row_count - 1

  define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)
  # grid.show_all

  # Header
  left_header = date.strftime("%B %-d, %Y") # date.strftime("Week %W")
  right_header = date.strftime("%A") # date.strftime("Day %j")
  grid([0, 0],[1, 2]).bounding_box do
    text left_header, size: 20, align: :left
  end
  grid([0, 2],[1, 3]).bounding_box do
    text right_header, size: 20, align: :right
  end

  # Daily metrics
  grid([1, 0], [4, 3]).bounding_box do
    dash 2, phase: 1
    stroke_bounds
    undash

    translate 10, -10 do
      text "Daily Metrics", color: MEDIUM_COLOR
    end

    stroke do
      rectangle [bounds.bottom_right[0] - 20, bounds.bottom_right[1] + 20], 10, 10
    end

    translate -27, 7 do
      text "Shutdown Complete", color: MEDIUM_COLOR, align: :right, valign: :bottom
    end
  end

  # Tasks / Notes
  grid([5, 0], [5, 1]).bounding_box do
    translate 6, 0 do
      text "Tasks:", color: DARK_COLOR, valign: :center
    end
  end
  grid([5, 2], [5, 3]).bounding_box do
    translate 6, 0 do
      text "Notes:", color: DARK_COLOR, valign: :center
    end
  end

  # Horizontal lines
  (5..last_row).each do |row|
    grid([row, 0], [row, 3]).bounding_box do
      stroke_line bounds.bottom_left, bounds.bottom_right
    end
  end

  # Vertical line
  grid([6, 1], [last_row, 1]).bounding_box do
    dash 2, phase: 1
    stroke_line(bounds.top_right, bounds.bottom_right)
    undash
  end

  # Checkboxes
  checkbox_padding = 6
  checkbox_size = grid.row_height - (2 * checkbox_padding)
  (6..last_row).each do |row|
    grid(row, 0).bounding_box do
      draw_checkbox checkbox_size, checkbox_padding
    end
  end
end

def time_page date
  start_new_page(margin: RIGHT_PAGE_MARGINS)

  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  first_column = 0
  last_column = COLUMN_COUNT - 1
  fist_hour_row = header_row_count
  last_hour_row = header_row_count + body_row_count - 1

  define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)

  # Header
  #left_header = date.strftime("%B %-d, %Y")
  left_header = date.strftime("Week %W » Day %j")
  # right_header = date.strftime("Day %j")
  right_header = date.strftime("%A")
  sub_header = "#{business_days_left_in_year(date)} work days left in year"
  grid([0, first_column],[1, 1]).bounding_box do
    text left_header, size: 20, align: :left
  end
  grid([0, 2],[0, last_column]).bounding_box do
    text right_header, size: 20, align: :right
  end
  grid([1, first_column],[1, last_column]).bounding_box do
    text sub_header, color: MEDIUM_COLOR, align: :left
  end

  # Hour labels
  (0...HOUR_COUNT).each do |hour|
    grid(hour * 2 + fist_hour_row, -1).bounding_box do
      if HOUR_LABELS[hour]
        translate(-4, 0) { text HOUR_LABELS[hour].to_s, align: :right, valign: :center }
      end
    end
  end

  # Horizontal lines
  ## Top line
  stroke_color MEDIUM_COLOR
  overhang = 24
  grid([fist_hour_row, first_column], [fist_hour_row, last_column]).bounding_box do
    stroke_line([bounds.top_left[0] - overhang, bounds.top_left[1]], bounds.top_right)
  end
  (fist_hour_row..last_hour_row).step(2) do |row|
    ## Half hour lines
    grid([row, first_column], [row, last_column]).bounding_box do
      dash 2, phase: 1
      stroke_line([bounds.bottom_left[0] - overhang, bounds.bottom_left[1]], bounds.bottom_right)
      undash
    end
    ## Hour lines
    grid([row + 1, first_column], [row + 1, last_column]).bounding_box do
      stroke_line([bounds.bottom_left[0] - overhang, bounds.bottom_left[1]], bounds.bottom_right)
    end
  end

  # Vertical lines
  (0..COLUMN_COUNT).each do |col|
    grid([header_row_count, col], [last_hour_row, col]).bounding_box do
      dash 2, phase: 1
      stroke_line(bounds.top_left, bounds.bottom_left)
      undash
    end
  end
end


def weekend_page saturday, sunday
  start_new_page(margin: LEFT_PAGE_MARGINS)

  header_row_count = 2
  task_row_count = HOUR_COUNT
  hour_row_count = HOUR_COUNT
  body_row_count = header_row_count + task_row_count + hour_row_count

  define_grid(columns: COLUMN_COUNT, rows: body_row_count, gutter: 0)
  # grid.show_all

  # Header
  left_header = saturday.strftime("%A")
  left_sub_header = saturday.strftime("%B %-d")
  right_header = sunday.strftime("%A")
  right_sub_header = sunday.strftime("%B %-d")
  grid([0, 0],[0, 1]).bounding_box do
    text left_header, size: 20, align: :left
  end
  grid([1, 0],[1, 1]).bounding_box do
    text left_sub_header, color: MEDIUM_COLOR, align: :left
  end
  grid([0, 2],[0, 3]).bounding_box do
    text right_header, size: 20, align: :left
  end
  grid([1, 2],[1, 3]).bounding_box do
    text right_sub_header, color: MEDIUM_COLOR, align: :left
  end

  task_start_row = header_row_count
  task_last_row = task_start_row + task_row_count - 1

  # Tasks / Notes
  grid([task_start_row, 0], [task_start_row, 1]).bounding_box do
    translate 6, 0 do
      text "Tasks:", color: DARK_COLOR, valign: :center
    end
  end
  grid([task_start_row, 2], [task_start_row, 3]).bounding_box do
    translate 6, 0 do
      text "Tasks:", color: DARK_COLOR, valign: :center
    end
  end

  # Horizontal lines
  (task_start_row..task_last_row).each do |row|
    grid([row, 0], [row, 3]).bounding_box do
      stroke_line bounds.bottom_left, bounds.bottom_right
    end
  end

  # Vertical line
  grid([task_start_row + 1, 1], [task_last_row, 1]).bounding_box do
    dash 2, phase: 1
    stroke_line(bounds.top_right, bounds.bottom_right)
    undash
  end

  # Checkboxes
  checkbox_padding = 6
  checkbox_size = grid.row_height - (2 * checkbox_padding)
  ((task_start_row + 1)..task_last_row).each do |row|
    grid(row, 0).bounding_box do
      draw_checkbox checkbox_size, checkbox_padding
    end
    grid(row, 2).bounding_box do
      draw_checkbox checkbox_size, checkbox_padding
    end
  end

  # TODO figure out some hour grid to go here.
end

Prawn::Document.generate(FILE_NAME, margin: RIGHT_PAGE_MARGINS) do
  font_families.update(
    'Futura' => {
      normal: { file: OSX_FONT_PATH, font: 'Futura Medium' },
      italic: { file: OSX_FONT_PATH, font: 'Futura Medium Italic' },
      # bold: { file: OSX_FONT_PATH, font: 'Futura Bold' },
      bold: { file: OSX_FONT_PATH, font: 'Futura Condensed ExtraBold' },
      condensed: { file: OSX_FONT_PATH, font: 'Futura Condensed Medium' },
    }
  )
  font("Futura")
  stroke_color MEDIUM_COLOR
  line_width(0.5)

  sunday = if ARGV.empty?
      date = DateTime.now.to_date
      puts "Generating pages for the next week"
      date.next_day(7 - date.wday)
    else
      date = DateTime.parse(ARGV.first).to_date
      puts "Parsed #{date} from arguments"
      date.prev_day(date.wday)
    end

  WEEKS.times do |week|
    unless week.zero?
      # ...then the page for the week
      start_new_page(margin: RIGHT_PAGE_MARGINS)
    end

    monday = sunday.next_day(1)
    friday = sunday.next_day(5)
    puts "Generate pages for week #{monday.strftime('%W')}: #{monday.strftime('%A, %B %-d, %Y')} through #{friday.strftime('%A, %B %-d, %Y')} in #{FILE_NAME}"
    week_ahead_page monday, friday

    # I just want week days
    (1..5).each do |i|
      day = sunday.next_day(i)
      task_page day
      time_page day
    end

    weekend_page sunday.next_day(6), sunday.next_day(7)

    sunday = sunday.next_day(7)
  end
end

