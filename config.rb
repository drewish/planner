HOUR_LABELS = [nil, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, nil, nil]
HOUR_COUNT = HOUR_LABELS.length
COLUMN_COUNT = 4
LIGHT_COLOR = 'AAAAAA'
MEDIUM_COLOR = '888888'
DARK_COLOR   = '000000'
DATE_FULL_START = '%A, %B %-d'
DATE_FULL_END = ' — %A, %B %-d, %Y'
DATE_FULL = '%A, %B %-d, %Y'
DATE_LONG = '%B %-d, %Y'
DATE_DAY = '%A'
OSX_FONT_PATH = "/System/Library/Fonts/Supplemental/Futura.ttc"
FONTS = {
  'Futura' => {
    normal: { file: OSX_FONT_PATH, font: 'Futura Medium' },
    italic: { file: OSX_FONT_PATH, font: 'Futura Medium Italic' },
    bold: { file: OSX_FONT_PATH, font: 'Futura Condensed ExtraBold' },
    condensed: { file: OSX_FONT_PATH, font: 'Futura Condensed Medium' },
  }
}
PAGE_SIZE = 'LETTER' # Could also do 'A4'
# Order is top, right, bottom, left
LEFT_PAGE_MARGINS = [36, 72, 36, 36]
RIGHT_PAGE_MARGINS = [36, 36, 36, 72]

# Adjust the quarters to a fiscal year, 1 for Jan, 2 for Feb, etc.
Q1_START_MONTH = 2
QUARTERS_BY_MONTH = (1..12).map { |month| (month / 3.0).ceil }.rotate(Q1_START_MONTH - 1).unshift(nil)

# Use these if you have sprints of a weekly interval
SPRINT_EPOCH = Date.parse('2023-01-04')
SPRINT_LENGTH = 14

# Names by day of week, 0 is Sunday.
OOOS_BY_WDAY = [nil, nil, ['Juan'], ['Kelly'], nil, ['Alex', 'Edna'], nil]

# Repeating tasks by day of week, 0 is Sunday. Nested index is the row.
TASKS_BY_WDAY = [
  { 0 => 'Plan meals' },
  { 0 => 'Update standup notes', 12 => 'Italian', 13 => 'Walk dog' },
  { 0 => 'Update standup notes', 12 => 'Italian', 13 => 'Walk dog' },
  { 0 => 'Update standup notes', 12 => 'Italian', 13 => 'Walk dog' },
  { 0 => 'Update standup notes', 12 => 'Italian', 13 => 'Walk dog' },
  { 0 => 'Update standup notes', 12 => 'Italian', 13 => 'Walk dog' },
  { 0 => 'Plan next week' },
]
