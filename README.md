# Generate Time-Block Planner Pages

I'm a big fan of [Cal Newport's Time-Block Planner](https://www.timeblockplanner.com) 
but I didn't like having unused weekend pages and got tired of writing in the 
dates so I wrote this script to generate my own version of it. It generates a 
PDF with a week's worth of 8.5 x 11 inch pages.

I'm also a fan of [Manager Tools' 1-on-1s](https://www.manager-tools.com/map-universe/one-ones),
so I incorporated a version of their meeting form. You specify which people you 
meet every week, and you'll get a page for each.

Take a look at a [sample](sample.pdf) and see what you think. If it's not to 
your liking, feel free to customize it, or try out some of the other variations people have put together:
- [jlorenzetti's fork](https://github.com/jlorenzetti/planner) generates A4 
pages in Helvetica, and omits the 1-on-1 forms.
  - [pzula's fork](https://github.com/pzula/planner) is based off of jlorenzetti's but scales it down to A5.
- [Hyunggilwoo's fork](https://github.com/Hyunggilwoo/planner) uses UbuntuMono
and omits 1-on-1 forms. It looks like a good choice for Ubuntu users.

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
./planner.rb
```

You can generate pages for a different weeks by passing in the date:
```
./planner.rb 2022-05-27
```

On a Mac you can send the PDF directly to your printer:
```
lpr time_block_pages.pdf
```

## Limitations

Probably only works on a Mac since it hardcodes the font path.
