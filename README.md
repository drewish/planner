# Generate Time-Block Planner Pages

I'm a big fan of [Cal Newport's Time-Block Planner](https://www.timeblockplanner.com) but I didn't like 
having unused weekend pages and got tired of writing in the dates so I wrote this script to generate
my take on it. It generates a PDF with a week's worth of 8.5 x 11 inch pages. You can take a look at a
[sample](sample.pdf) and see what you think.

## Installation

Assuming you've got [Ruby](http://www.ruby-lang.org/en/) and [Bundler](https://bundler.io)
installed you can just run:
```
git clone git@github.com:drewish/planner.git
cd planner
bundle install
```

## Usage

It assumes you want to generate pages for the next week so there are no options:
```
bundle exec planner.rb
```

## Limitations

Probably only works on a Mac since it hardcodes the font path.
