#!/usr/bin/env ruby

require_relative './shared'
FILE_NAME = "notes.pdf"

puts "Generating a notes page into #{FILE_NAME}"

options = { locale: 'en' }
OptionParser.new do |parser|
parser.banner = "Usage: #{$PROGRAM_NAME} [options]"
parser.on('-l', '--locale LOCALE', 'Locale to use for internationalization')
parser.on("-h", "--help", "Prints this help") do
  puts parser
  exit
end
end.parse!(into: options)

init_i18n(options[:locale])

pdf = init_pdf
hole_punches pdf

heading_left = I18n.t('notes_heading')
notes_page pdf, heading_left
begin_new_page pdf, :left
notes_page pdf, heading_left

pdf.render_file FILE_NAME
