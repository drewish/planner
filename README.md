# Generate Time-Block Planner Pages

I'm a big fan of [Cal Newport's Time-Block Planner](https://www.timeblockplanner.com)
but I didn't like a few things and wanted to make my own version. So wrote this
ruby script generate 8.5 x 11 PDFs with my take on it. You can take a look at a [sample week](sample.pdf).

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
bundle exec ruby planner.rb
```

## Limitations

Probably only works on a Mac since it hardcodes the font path.
