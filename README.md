# Generate Time-Block Planner Pages

I'm a big fan of [Cal Newport's Time-Block Planner](https://www.timeblockplanner.com)
but I didn't like a few things and wanted to make my own version. So wrote this
ruby script generate 8.5 x 11 PDFs with my take on it.

Assuming you've got [Ruby](http://www.ruby-lang.org/en/) and [Bundler](https://bundler.io)
installed you can just run:
```
bundle install
```
And then generate the next weeks pages with:
```
bundle exec ruby planner.rb
```

It's opinionated:

- Includes the dates for you
- No weekend pages
- A single page for the week ahead... might change that since you end up with a blank back right now.
