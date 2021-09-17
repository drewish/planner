require "prawn"
require 'pry'
require 'date'

WEEKS = 1
HOUR_LABELS = [nil, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, nil, nil]
HOUR_COUNT = HOUR_LABELS.length
COLUMN_COUNT = 5
MEDIUM_COLOR = '666666'
DARK_COLOR   = '000000'
OSX_FONT_PATH = "/System/Library/Fonts/Supplemental/Futura.ttc"
FILE_NAME = "time_block_pages.pdf"

def week_page sunday
  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  last_column = COLUMN_COUNT - 1
  last_row = header_row_count + body_row_count - 1

  define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)
  # grid.show_all

  # Header
  grid([0, 1],[0, 2]).bounding_box do
    text "The Week Ahead", inline_format: true, size: 20, align: :left
  end
  grid([0, 3],[0, last_column]).bounding_box do
    text sunday.strftime("Week <b>%W</b>"), inline_format: true, size: 20, align: :right
  end

  # Horizontal lines
  (1..last_row).each do |row|
    grid([row, 1], [row, last_column]).bounding_box do
      stroke_line bounds.bottom_left, bounds.bottom_right
    end
  end
end

def task_page date
  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  last_row = header_row_count + body_row_count - 1

  define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)

  # Header
  grid([0, 0],[1, 2]).bounding_box do
    text date.strftime("Week <b>%W</b>"), inline_format: true, size: 20, align: :left
  end
  grid([0, 2],[1, 3]).bounding_box do
    text date.strftime("Day <b>%j</b>"), inline_format: true, size: 20, align: :right
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

  # Tasks / Ideas
  grid([5, 0], [5, 1]).bounding_box do
    translate 10, 0 do
      text "Tasks:", color: DARK_COLOR, valign: :center
    end
  end
  grid([5, 2], [5, 3]).bounding_box do
    translate 10, 0 do
      text "Ideas:", color: DARK_COLOR, valign: :center
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
      dash 1, phase: 0.5
      rectangle [bounds.top_left[0] + checkbox_padding, bounds.top_left[1] - checkbox_padding], checkbox_size, checkbox_size
      stroke
      undash
    end
  end
end

def time_page date
  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  last_column = COLUMN_COUNT - 1
  fist_hour_row = header_row_count
  last_hour_row = header_row_count + body_row_count - 1

  define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)

  # Header
  grid([0, 1],[1, 2]).bounding_box do
    text date.strftime("%B <b>%-d</b>, %Y"), inline_format: true, size: 20, align: :left
  end

  grid([0, 3],[1, last_column]).bounding_box do
    text date.strftime("%A"), size: 20, align: :right
  end

  # Hour labels
  (0...HOUR_COUNT).each do |hour|
    grid(hour * 2 + fist_hour_row, 0).bounding_box do
      if HOUR_LABELS[hour]
        translate(-4, 0) { text HOUR_LABELS[hour].to_s, align: :right, valign: :center }
      end
    end
  end

  # Horizontal lines
  ## Top line
  stroke_color MEDIUM_COLOR
  overhang = grid.column_width / 4
  grid([fist_hour_row, 1], [fist_hour_row, last_column]).bounding_box do
    stroke_line([bounds.top_left[0] - overhang, bounds.top_left[1]], bounds.top_right)
  end
  (fist_hour_row..last_hour_row).step(2) do |row|
    ## Half hour lines
    grid([row, 1], [row, last_column]).bounding_box do
      dash 2, phase: 2
      stroke_line([bounds.bottom_left[0] - overhang, bounds.bottom_left[1]], bounds.bottom_right)
      undash
    end
    ## Hour lines
    grid([row + 1, 1], [row + 1, last_column]).bounding_box do
      stroke_line([bounds.bottom_left[0] - overhang, bounds.bottom_left[1]], bounds.bottom_right)
    end
  end

  # Vertical lines
  (0...COLUMN_COUNT).each do |col|
    grid([header_row_count, col], [last_hour_row, col]).bounding_box do
      dash 2, phase: 1
      stroke_line(bounds.top_right, bounds.bottom_right)
      undash
    end
  end
end


Prawn::Document.generate(FILE_NAME) do
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

  date = DateTime.now.to_date
  sunday = date.next_day(7 - date.wday)

  WEEKS.times do
    puts "Generate pages for the week of #{sunday.strftime('%B %-d, %Y')} in #{FILE_NAME}"
    week_page sunday

    # I just want week days
    (1..5).each do |i|
      day = sunday.next_day(i)
      start_new_page
      task_page day

      start_new_page
      time_page day
    end

    sunday = sunday.next_day(7)
  end
end
