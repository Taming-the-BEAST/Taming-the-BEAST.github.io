# Taming the BEAST website

Taming the BEAST is a platform for collating a comprehensive and cohesive set of BEAST 2 tutorials in one location, providing researchers the resources necessary to learn how to perform analyses in BEAST 2. This GitHub repository stores the source code for the Taming the BEAST website. The site is based on Trevor Bedford's lab website ([http://bedford.io](http://bedford.io)).

## Build site

To build the website locally, clone the repo with:

```
git clone https://github.com/Taming-the-BEAST/blotter.git
```

Then install necessary Ruby dependencies by running `bundle install` from within the `blotter` directory.  After this, the site can be be built with:

```
bundle exec jekyll build
```

To view the site, run `bundle exec jekyll serve` and point a browser to `http://localhost:4000/`.  More information on Jekyll can be found [here](http://jekyllrb.com/).

To include the tutorials, preprocessing scripts are necessary to clone tutorial repos and update Jekyll metadata. This can be accomplished with:

```
ruby _scripts/update-and-preprocess.rb
```

Then `bundle exec jekyll build` works as normal.

See [Building a local copy of the site](https://taming-the-beast.github.io/contribute/Building-a-local-copy-of-the-site/) for more information.


## License

All source code in this repository, consisting of files with extensions `.html`, `.css`, `.less`, `.rb` or `.js`, is freely available under an MIT license, unless otherwise noted within a file. 

**The MIT License (MIT)**

Copyright (c) 2016-2017 Louis du Plessis, 2013-2016 Trevor Bedford

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


## TODOs

### Website source
- Add RSS/Atom feed for updated tutorials
- Add link for RSS/Atom feeds
- Add BEAST version to tutorial layout page
- Clean up repository and remove unnecessary files


### Website contents
- Write a proper style guide for tutorials (current style guide is just a markdown syntax cheatsheet)
- Rewrite documentation on adding tutorials (mentioning style to be followed)
- Add documentation for converting between Markdown and Latex
- Need new news posts (funding for future, new style guide etc.)
- About page should be rewritten to make sure it is concurrent with the paper.


### Tutorials
- Update Latex and layout for all latex tutorials (should use auto-generated latex from markdown tutorial)
- Fix Structured coalescent tutorial (estimate gamma shape)
- Fix Structured birth-death tutorial (estimate gamma shape)
- Add FBD tutorial (need precooked runs and xml)
- Structured coalescent tutorial markdown
- FBD tutorial markdown
