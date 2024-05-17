# Hours shown on the day schedule. You can leave nils if you want a blank to write in.
HOUR_LABELS = [nil, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, nil, nil]
HOUR_COUNT = HOUR_LABELS.length
COLUMN_COUNT = 4
LIGHT_COLOR = 'AAAAAA'
MEDIUM_COLOR = '888888'
DARK_COLOR   = '000000'
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
QUARTERS_BY_MONTH = (1..12).map { |month| (month / 3.0).ceil }.rotate(1 - Q1_START_MONTH).unshift(nil)

# Adjust the start of semesters
SUMMER_SEMESTER_START = 4 # April
WINTER_SEMESTER_START = 10 # October

# Use these if you have sprints of a weekly interval
USE_SPRINTS = false
SPRINT_EPOCH = Date.parse('2023-01-04')
SPRINT_LENGTH = 14

# Names by day of week, 0 is Sunday.
OOOS_BY_WDAY = [nil, nil, ['Lilian', 'Hendrik', 'Marvin', 'Maged', 'Marthe' ], ['Toni'], ['Leonard'], nil, nil]

# Repeating tasks by day of week, 0 is Sunday. Nested index is the row.
TASKS_BY_WDAY = [
  { 0 => 'Wochenplan' }, # Sonntag
  { 0 => 'Unterschriftenmappe', # Montag
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'Fragen für die Profrunde',
      4 => 'ForschMedi updaten',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Dienstag
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'Standup-Notizen (Hendrik, Marthe, Marvin, Maged)',
      4 => 'SMNF Folien',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Mittwoch
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'OSE check',
      4 => 'Standup-Notizen (Toni)',
      5 =>  'Jour-Fixe Agenda',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Donnerstag
      1 => 'Trello',
      2 => 'Email-Triage',
      3 => 'Standup-Notizen (Leonard, Lilian)',
      4 => 'SMNF updaten',
      15 => 'Emails'
    },
  { 0 => 'Unterschriftenmappe', # Freitag
      1 => 'Trello',
      2 => 'Email-Triage',
      14 => 'Unterschriften Mappe wegsortieren',
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
