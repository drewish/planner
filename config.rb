# Hours shown on the day schedule. You can leave nils if you want a blank to write in.
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

# Load internationalization strings
I18n.load_path += Dir[File.join(__dir__, 'config', 'locales', '*.{rb,yml}')]
I18n.available_locales = [:de, :en]
I18n.default_locale = :de

# Adjust the quarters to a fiscal year, 1 for Jan, 2 for Feb, etc.
Q1_START_MONTH = 1
QUARTERS_BY_MONTH = (1..12).map { |month| (month / 3.0).ceil }.rotate(1 - Q1_START_MONTH).unshift(nil)

# Adjust the start of semesters
SUMMER_SEMESTER_START = 4 # April
WINTER_SEMESTER_START = 10 # October

# Use these if you have sprints of a weekly interval
USE_SPRINTS = false
SPRINT_EPOCH = Date.parse('2023-01-04')
SPRINT_LENGTH = 14

# Names by day of week, 0 is Sunday.
OOOS_BY_WDAY = [nil, nil, ['Hendrik', 'Marvin', 'Maged', 'Marthe' ], ['Toni'], ['Leonard','Lilian'], nil, nil]

# Repeating tasks by day of week, 0 is Sunday. Nested index is the row.
TASKS_BY_WDAY = [
  { 0 => 'Wochenplan' }, # Sonntag
  { 0 => 'Unterschriftenmappe', # Montag
      1 => 'Email-Triage',
      2 => 'Fragen für die Profrunde',
      3 => 'ForschMedi updaten',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Dienstag
      1 => 'Email-Triage',
      2 => 'Standup-Notizen (Hendrik, Marthe, Marvin, Maged)',
      3 => 'SMNF Folien',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Mittwoch
      1 => 'Email-Triage',
      2 => 'OSE check',
      3 => 'Standup-Notizen (Toni)',
      4 =>  'Jour-Fixe Agenda',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Donnerstag
      1 => 'Email-Triage',
      2 => 'Standup-Notizen (Leonard, Lilian)',
      3 => 'SMNF updaten',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Freitag
      1 => 'Email-Triage',
      15 => 'Emails',
      16 => 'Week-Shutdown',
      17 => 'Nächste Woche drucken'},
  { 0 => 'Sport' },
]

# Repeating Appointments by day of week, 0 is Sunday. Nested index is a value in HOUR_LABELS.
#APPOINTMENTS_BY_WDAY = [
#  {},
#  {},
#  {},
#  {},
#  {},
#  {},
#  {},
#]

require_relative './summer'
