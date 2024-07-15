#!/usr/bin/env ruby

require_relative './shared'
FILE_NAME = "time_block_pages.pdf"

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
  days = business_days_between(date, Date.new(date.year, 12, 31))
  I18n.t('business_days_in_year', count: days)
end

def business_days_left_in_sprint(date)
  # Use this if you have sprints that start on the 1st and 15th.
  #sprint_end = Date.new(date.year, date.month, date.mday <= 15 ? 15 : -1)

  # Use this if you have two week sprints from a given day.
  sprint_start = SPRINT_EPOCH.step(date, SPRINT_LENGTH).to_a.last
  sprint_end = sprint_start.next_day(SPRINT_LENGTH - 1)

  days = business_days_between(date, sprint_end)
  I18n.t('days_left_in_sprint', count: days)
end

def quarter(date)
  QUARTERS_BY_MONTH[date.month]
end

# pick summer or winter semester depending on the month
def semester_year(date)
  if date.month >= SUMMER_SEMESTER_START && date.month < WINTER_SEMESTER_START
    I18n.l(date, format: :year)
  else
    "#{I18n.l(date, format: :year)} / #{I18n.l(date.next_year, format: :year)}"
  end
end

# * * *

def quarter_ahead pdf, first_day, last_day
  heading_left = I18n.t('quarter_plan_heading')
  subheading_left = date_range(first_day, last_day)
  heading_right = I18n.t('quarter', number: quarter(first_day))
  subheading_right = I18n.l(last_day, format: :year)

  # We let the caller start our page for us but we'll do both sides
  hole_punches pdf
  notes_page pdf, heading_left, subheading_left, heading_right, subheading_right
  begin_new_page pdf, :left
  notes_page pdf, heading_left, subheading_left, heading_right, subheading_right
  begin_new_page pdf, :right
end

def week_ahead_page pdf, first_day, last_day
  heading_left = I18n.t('week_plan_heading')
  subheading_left = date_range(first_day, last_day)
  heading_right = first_day.strftime("#{I18n.t('week')} %W")
  subheading_right = I18n.t('quarter', number: quarter(first_day))

  # We don't start our own page since we don't know if this is the first week or one
  # of several weeks in a file.
  hole_punches pdf
  notes_page pdf, heading_left, subheading_left, heading_right, subheading_right
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
  # pdf.grid.show_all

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
  ((first_row + 1)..last_row).each do |row|
    pdf.grid(row, 0).bounding_box do
      draw_checkbox pdf
    end
  end
end

def daily_tasks_page pdf, date, metrics_rows = 5
  begin_new_page pdf, :left

  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  last_row = header_row_count + body_row_count - 1

  pdf.define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)
  # pdf.grid.show_all

  # Header
  left_header = I18n.l(date, format: :medium)
  right_header = I18n.l(date, format: :weekday)
  pdf.grid([0, 0],[1, 2]).bounding_box do
    pdf.text left_header, heading_format(align: :left)
  end
  pdf.grid([0, 2],[1, 3]).bounding_box do
    pdf.text right_header, heading_format(align: :right)
  end

  # Daily metrics
  if metrics_rows > 0
    pdf.grid([1, 0], [metrics_rows, 3]).bounding_box do
      pdf.dash [1, 2]
      pdf.stroke_bounds
      pdf.undash

      pdf.translate 6, -6 do
        pdf.text I18n.t('daily_metrics'), color: MEDIUM_COLOR
      end
    end

    pdf.grid([metrics_rows, 2], [metrics_rows, 3]).bounding_box do
      draw_checkbox pdf, 6, I18n.t('shutdown_complete')
    end
  end

  # Tasks / Notes
  task_note_start = metrics_rows + 1
  pdf.grid([task_note_start, 0], [task_note_start, 1]).bounding_box do
    pdf.translate 6, 0 do
      pdf.text I18n.t('tasks'), color: DARK_COLOR, valign: :center
    end
  end
  pdf.grid([task_note_start, 2], [task_note_start, 3]).bounding_box do
    pdf.translate 6, 0 do
      pdf.text I18n.t('notes'), color: DARK_COLOR, valign: :center
    end
  end

  # Horizontal lines
  (task_note_start..last_row).each do |row|
    pdf.grid([row, 0], [row, 3]).bounding_box do
      pdf.stroke_line pdf.bounds.bottom_left, pdf.bounds.bottom_right
    end
  end

  # Vertical line
  pdf.grid([task_note_start + 1, 1], [last_row, 1]).bounding_box do
    pdf.dash [1, 2], phase: 2
    pdf.stroke_line(pdf.bounds.top_right, pdf.bounds.bottom_right)
    pdf.undash
  end

  # Checkboxes
  checkbox_padding = 6
  ((task_note_start + 1)..last_row).each_with_index do |row, index|
    # Make the box wider than needed to avoid wrapping if the task name is too long
    pdf.grid([row, 0], [row, 4]).bounding_box do
      draw_checkbox pdf, checkbox_padding, TASKS_BY_WDAY[date.wday][index]
    end
  end
end

def daily_calendar_page pdf, date
  begin_new_page pdf, :right

  header_row_count = 2
  body_row_count = HOUR_COUNT * 2
  first_column = 0
  last_column = COLUMN_COUNT - 1
  fist_hour_row = header_row_count
  last_hour_row = header_row_count + body_row_count - 1

  pdf.define_grid(columns: COLUMN_COUNT, rows: header_row_count + body_row_count, gutter: 0)

  # Header
  left_header = I18n.l(date, format: :medium)
  right_header = I18n.l(date, format: :weekday)
  left_subhed = date.strftime("#{I18n.t('quarter', number: quarter(date))} #{I18n.t('week')} %W #{I18n.t('day')} %j")
  # right_subhed = business_days_left_in_year(date)
  right_subhed = business_days_left_in_sprint(date)
  pdf.grid([0, first_column],[1, 1]).bounding_box do
    pdf.text left_header, heading_format(align: :left)
  end
  pdf.grid([0, 2],[0, last_column]).bounding_box do
    pdf.text right_header, heading_format(align: :right)
  end
  pdf.grid([1, first_column],[1, last_column]).bounding_box do
    pdf.text left_subhed, subheading_format(align: :left)
  end
  pdf.grid([1, first_column],[1, last_column]).bounding_box do
    pdf.text right_subhed, subheading_format(align: :right)
  end

  (0...HOUR_COUNT).each do |hour|
    row = hour * 2 + fist_hour_row
    # Hour labels
    if hour_label = HOUR_LABELS[hour]
      pdf.grid(row, -1).bounding_box do
        pdf.translate(-4, 0) { pdf.text hour_label.to_s, align: :right, valign: :center }
      end
    end

    # Default appointments
    if appointment_label = APPOINTMENTS_BY_WDAY[date.wday][HOUR_LABELS[hour]]
      pdf.grid([row, first_column], [row, last_column]).bounding_box do
        pdf.translate(4, 0) do
          pdf.text appointment_label.to_s, color: MEDIUM_COLOR, align: :left, valign: :center
        end
      end
    end
  end

  # Horizontal lines
  ## Top line
  pdf.stroke_color MEDIUM_COLOR
  overhang = 24
  pdf.grid([fist_hour_row, first_column], [fist_hour_row, last_column]).bounding_box do
    pdf.stroke_line([pdf.bounds.top_left[0] - overhang, pdf.bounds.top_left[1]], pdf.bounds.top_right)
  end
  (fist_hour_row..last_hour_row).step(2) do |row|
    ## Half hour lines
    pdf.dash [1, 2], phase: 2
    pdf.grid([row, first_column], [row, last_column]).bounding_box do
      pdf.stroke_line([pdf.bounds.bottom_left[0] - overhang, pdf.bounds.bottom_left[1]], pdf.bounds.bottom_right)
    end
    pdf.undash
    ## Hour lines
    pdf.grid([row + 1, first_column], [row + 1, last_column]).bounding_box do
      pdf.stroke_line([pdf.bounds.bottom_left[0] - overhang, pdf.bounds.bottom_left[1]], pdf.bounds.bottom_right)
    end
  end

  # Vertical lines
  (0..COLUMN_COUNT).each do |col|
    pdf.grid([header_row_count, col], [last_hour_row, col]).bounding_box do
      pdf.dash [1, 2], phase: 2
      pdf.stroke_line(pdf.bounds.top_left, pdf.bounds.bottom_left)
      pdf.undash
    end
  end
end


def weekend_page pdf, saturday, sunday
  begin_new_page pdf, :left

  header_row_count = 2
  hour_row_count = HOUR_COUNT
  # TODO should have one constant for grid's number of rows to use here.
  # instead we'll just assume it's always 2x hours. We print a row per hour
  # and one blank line as a divider.
  task_row_count = 2 * HOUR_COUNT - hour_row_count - 1
  body_row_count = header_row_count + task_row_count + hour_row_count

  # Use a grid to do the math to divide the page into two columns:
  pdf.define_grid(columns: 2, rows: 1, column_gutter: 24, row_gutter: 0)
  first = pdf.grid(0,0)
  second = pdf.grid(0,1)
  # Then use that to build a bounding box for each column and redefine the grid in there.
  work_areas = [
    [saturday, first.top_left, { width: first.width, height: first.height }],
    [sunday, second.top_left, { width: second.width, height: second.height }]
  ].each do |date, point, options|
    pdf.bounding_box(point, options) do
      pdf.define_grid(columns: 2, rows: body_row_count, gutter: 0)
      # pdf.grid.show_all

      # Header
      left_header = I18n.l(date, format: :weekday)
      left_sub_header = I18n.l(date, format: :medium)
      pdf.grid([0, 0],[0, 1]).bounding_box do
        pdf.text left_header, heading_format(align: :left)
      end
      pdf.grid([1, 0],[1, 1]).bounding_box do
        pdf.text left_sub_header, subheading_format(align: :left)
      end

      task_start_row = header_row_count
      task_last_row = task_start_row + task_row_count - 1

      # Task lable
      pdf.grid([task_start_row, 0], [task_start_row, 1]).bounding_box do
        pdf.translate 6, 0 do
          pdf.text I18n.t('tasks'), color: DARK_COLOR, valign: :center
        end
      end

      # Horizontal lines
      (task_start_row..task_last_row).each do |row|
        pdf.grid([row, 0], [row, 1]).bounding_box do
          pdf.stroke_line pdf.bounds.bottom_left, pdf.bounds.bottom_right
        end
      end

      # Checkboxes
      checkbox_padding = 6
      ((task_start_row + 1)..task_last_row).each_with_index do |row, index|
        pdf.grid(row, 0).bounding_box do
          draw_checkbox pdf, checkbox_padding, TASKS_BY_WDAY[date.wday][index]
        end
      end

      # Hour Grid
      hour_start_row = task_last_row + 1
      hour_last_row = hour_start_row + hour_row_count - 1

      # Horizontal Lines
      (hour_start_row..hour_last_row).each do |row|
        pdf.grid([row, 0], [row, 1]).bounding_box do
          pdf.stroke_line pdf.bounds.bottom_left, pdf.bounds.bottom_right
        end
      end

      # Vertical lines
      overhang = 24
      pdf.dash [1, 2]
      pdf.grid([hour_start_row + 1, 0], [hour_last_row, 0]).bounding_box do
        pdf.stroke_line([pdf.bounds.top_left[0] + overhang, pdf.bounds.top_left[1]], [pdf.bounds.bottom_left[0] + overhang, pdf.bounds.bottom_left[1]])
      end
      # half plus change
      pdf.grid([hour_start_row + 1, 0], [hour_last_row, 0]).bounding_box do
        pdf.stroke_line([pdf.bounds.top_right[0] + overhang * 0.5, pdf.bounds.top_right[1]], [pdf.bounds.bottom_right[0] + overhang * 0.5, pdf.bounds.bottom_right[1]])
      end
      pdf.grid([hour_start_row + 1, 1], [hour_last_row, 1]).bounding_box do
        pdf.stroke_line(pdf.bounds.top_right, pdf.bounds.bottom_right)
      end
      pdf.undash

      # Hour labels
      (0...HOUR_COUNT).each do |hour|
        row = hour + hour_start_row + 1
        if hour_label = HOUR_LABELS[hour]
          pdf.grid(row, -1).bounding_box do
            pdf.translate(20, 0) { pdf.text hour_label.to_s, align: :right, valign: :center }
          end
        end

        if appointment_label = APPOINTMENTS_BY_WDAY[date.wday][HOUR_LABELS[hour]]
          pdf.grid([row, 0], [row, 2]).bounding_box do
            pdf.translate(overhang + 4, 0) {
              pdf.text appointment_label.to_s, color: MEDIUM_COLOR, align: :left, valign: :center
            }
          end
        end
      end
    end
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

  # Quarterly goals
  if sunday.month != next_sunday.month && (next_sunday.month % 3) == Q1_START_MONTH
    first = Date.new(next_sunday.year, next_sunday.month, 1)
    last = first.next_month(3).prev_day
    puts "Generating quarterly goals page for Q#{quarter(first)} #{date_range(first, last)}"
    quarter_ahead(pdf, first, last)
  end

  puts "Generating planner pages for #{date_range(monday, next_sunday)}"

  # Weekly goals
  week_ahead_page pdf, monday, next_sunday

  # Daily pages
  (1..5).each do |i|
    day = sunday.next_day(i)
    daily_tasks_page pdf, day
    daily_calendar_page pdf, day
  end

  # Weekend page
  weekend_page pdf, sunday.next_day(6), next_sunday

  sunday = sunday.next_day(7)
end

pdf.render_file FILE_NAME
