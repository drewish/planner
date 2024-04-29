#!/usr/bin/env ruby

require_relative './shared'
FILE_NAME = "notes.pdf"

puts "Generating a notes page into #{FILE_NAME}"

options = parse_options
init_i18n(options[:locale])

pdf = init_pdf
hole_punches pdf

# We let the caller start our page for us but we'll do both sides
heading_left = "Notes"
notes_page pdf, heading_left
begin_new_page pdf, :left
notes_page pdf, heading_left

pdf.render_file FILE_NAME
