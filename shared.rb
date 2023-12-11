require 'prawn'
require 'prawn/measurement_extensions'
require 'pry'
require 'date'

require_relative './config'

def init_pdf
  pdf = Prawn::Document.new(margin: RIGHT_PAGE_MARGINS, print_scaling: :none)
  pdf.font_families.update(FONTS)
  pdf.font(FONTS.keys.first)
  pdf.stroke_color MEDIUM_COLOR
  pdf.line_width(0.5)
  pdf
end

# Returns the date and an explanation of it
def parse_start_of_week
  unless ARGV.empty?
    date = DateTime.parse(ARGV.first).to_date
    return [date.prev_day(date.wday), "Parsed #{date} from arguments"]
  end

  date = DateTime.now.to_date
  if date.wday > 2
    [date.next_day(7-date.wday), "No date argument, using next week"]
  else
    [date.prev_day(date.wday), "No date argument, using this week"]
  end
end

def begin_new_page pdf, side
  margin = side == :left ? LEFT_PAGE_MARGINS : RIGHT_PAGE_MARGINS
  pdf.start_new_page size: PAGE_SIZE, layout: :portrait, margin: margin
  if side == :right
    hole_punches pdf
  end
end

def hole_punches pdf
  pdf.canvas do
    x = 25
    # Measuring it on the page it should be `[(1.25).in, (5.5).in, (9.75).in]`,
    # but depending on the printer driver it might do some scaling. With one
    # driver I printed a bunch of test pages and found that `[72, 392, 710]`
    # put it in the right place so your milage may vary.
    [(1.25).in, (5.5).in, (9.75).in].each do |y|
      pdf.horizontal_line x - 5, x + 5, at: y
      pdf.vertical_line y - 5, y + 5, at: x
    end
  end
end

def heading_format(overrides = {})
  { size: 20, color: DARK_COLOR }.merge(overrides)
end

def subheading_format(overrides = {})
  { size: 12, color: MEDIUM_COLOR }.merge(overrides)
end

def draw_checkbox pdf, checkbox_size, checkbox_padding, label = nil
  no_label = label.nil? || label.empty?
  original_color = pdf.stroke_color
  pdf.stroke_color(LIGHT_COLOR)
  pdf.dash([1, 2], phase: 0.5) if no_label
  pdf.rectangle [pdf.bounds.top_left[0] + checkbox_padding, pdf.bounds.top_left[1] - checkbox_padding], checkbox_size, checkbox_size
  pdf.stroke
  pdf.undash if no_label
  pdf.stroke_color(original_color)

  unless no_label
    pdf.translate checkbox_size + (2 * checkbox_padding), 0 do
      pdf.text label, color: MEDIUM_COLOR, valign: :center
    end
  end
end

# Caller needs to start the page, so this could be the first page.
def notes_page pdf, heading_left, subheading_left = nil, heading_right = nil, subheading_right = nil
  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  first_column = 0
  last_column = COLUMN_COUNT - 1
  first_row = header_row_count
  last_row = header_row_count + body_row_count - 1

  pdf.define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)
  # grid.show_all

  # Header Left
  if heading_left
    pdf.grid([0, first_column],[0, last_column]).bounding_box do
      pdf.text heading_left, heading_format(align: :left)
    end
  end
  if subheading_left
    pdf.grid([1, first_column],[1, last_column]).bounding_box do
      pdf.text subheading_left, subheading_format(align: :left)
    end
  end
  # Header Right
  if heading_right
    pdf.grid([0, 3],[0, last_column]).bounding_box do
      pdf.text heading_right, heading_format(align: :right)
    end
  end
  if subheading_right
    pdf.grid([1, 3],[1, last_column]).bounding_box do
      pdf.text subheading_right, subheading_format(align: :right)
    end
  end

  # Horizontal lines
  (first_row..last_row).each do |row|
    pdf.grid([row, first_column], [row, last_column]).bounding_box do
      pdf.stroke_line pdf.bounds.bottom_left, pdf.bounds.bottom_right
    end
  end

  # Checkboxes
  checkbox_padding = 6
  checkbox_size = pdf.grid.row_height - (2 * checkbox_padding)
  ((first_row + 1)..last_row).each do |row|
    pdf.grid(row, 0).bounding_box do
      draw_checkbox pdf, checkbox_size, checkbox_padding
    end
  end
end