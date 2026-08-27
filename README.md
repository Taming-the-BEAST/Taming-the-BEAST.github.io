# Taming the BEAST website

Taming the BEAST is a platform for collating a comprehensive and cohesive set of BEAST 2 tutorials in one location, providing researchers the resources necessary to learn how to perform analyses in BEAST 2. This GitHub repository stores the source code for the Taming the BEAST website. The site is based on Trevor Bedford's lab website ([http://bedford.io](http://bedford.io)).

## Build site

You can choose to set up a build environment locally or use a container image. Building and publishing with a container image can also be done directly on GitHub. You may also first use the testing set up to check any changes.

Repositoeries from which tutorials will be included in the build can be found at `_config.yaml` file. Edit this file if you would like to include/remove tutorials.

### Build and test within GitHub

#### Build and publish TESTING version of the site within GitHub

  All changes should be made to [blotter_test](https://github.com/Taming-the-BEAST/blotter_test) repository first:
  - sync [blotter_test](https://github.com/Taming-the-BEAST/blotter_test) with [blotter](https://github.com/Taming-the-BEAST/blotter)
  - push changes to [blotter_test](https://github.com/Taming-the-BEAST/blotter_test)
  - publish testing version of the website (this also tests that current container can build it):
    - go to the https://github.com/Taming-the-BEAST/web-testing repository
    - select `Actions` tab
    - select `Publish TTB website` action
    - click `Run workflow` and wait for it to finish.
  - Alternativelly, directly edit this repository and it will generate new file. But no changes will be saved to [blotter_test](https://github.com/Taming-the-BEAST/blotter_test), so you may loose them the next time you use `Publish TTB website` action to build and publish the site. 
  - On [web_testing](https://github.com/Taming-the-BEAST/web-testing) you can edit _config.yaml to have `baseurl: /web-testing` at the top, right after `url` line. This will make so you can avoid always adding `/web-testing/` to the url while testing your changes locally. **NEVER** commit and push this change to [blotter](https://github.com/Taming-the-BEAST/blotter)!!!s
  
  Hopefully, you can see your changes now on the [taming-the-beast.org/web-testing/](https://taming-the-beast.org/web-testing/)  

#### Build and publish PRODUCTION version of the site within GitHub   

  If you are ready to publish the public version of the website, repeat the same steps as above but from the https://github.com/Taming-the-BEAST/Taming-the-BEAST.github.io repository:
  - go to the [https://github.com/Taming-the-BEAST/web-testing](https://github.com/Taming-the-BEAST/web-testing) repository
  - select `Actions` tab
  - select `Publish TTB website` action
  - click `Run workflow` and wait for it to finish. 
  
  You should see the changes on the https://taming-the-beast.org website.

### Build site locally

#### Prerequisites

  The site requires:
  - **Ruby** (3.0+) and **Bundler** -- for Jekyll
  - **Node.js** (18+) and **npm** -- for Pagefind search indexing (optional)
  - **Pagefind** binary -- for full-text search indexing (optional)

  Using Docker avoids installing these manually. Otherwise, after getting Ruby and Bundler, make sure all Ruby dependencies are installed:
  ```
  bundle install
  ```

#### Using Docker (recommended)

  Pull the pre-built image from GitHub Container Registry:
  ```
  docker pull ghcr.io/taming-the-beast/ttb-web-build-env:latest
  ```

  You may need to authenticate first (requires a personal access token with `read:packages` permission):
  ```
  echo YOUR_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
  ```

  Alternatively, build the image locally from Dockerfile:
  ```
  docker build -t ttb-web-build-env .
  ```

  All of the commands below can be run inside the Docker container. Either prefix them with `docker run`, or start an interactive shell:
  ```
  docker run -it --rm -p 4000:4000 -v $(pwd):/page ttb-web-build-env bash
  ```

  The `-v $(pwd):/page` flag mounts your local files into the container. The `-p 4000:4000` flag exposes the Jekyll server to your browser at `http://localhost:4000/`.

#### Build pipeline

  Building the site has up to four stages. Depending on your needs, some can be skipped. See below for shortcuts, if you have npm (Node.js) available.

  **1. Fetch tutorials** (only needed if tutorials are not already present locally):
  ```
  ruby _scripts/update-and-preprocess.rb
  ```
  Clones tutorial repos from GitHub into `tutorials/`, runs preprocessing, and generates `_data/tutorials.yml`.

  **2. Preprocess tutorial markdown** (required before each build):
  
  Note: if you ran step 1, preprocessing was already included -- you can skip this step.

  ```
  ruby _scripts/preprocess-tutorial-markdown.rb
  ```
  Tutorials are stored as `README.md` in their repos. This script injects permalinks and layout metadata into the front matter so Jekyll renders them correctly. It also converts `.md` links to `.html`.

  **3. Build the site with Jekyll:**
  ```
  bundle exec jekyll build
  ```
  Generates the static site in `_site/`.

  **4. Index for full-text search** (optional):
  ```
  pagefind --site _site --glob "tutorials/**/*.html"
  ```
  Generates the Pagefind search index in `_site/pagefind/`. Without this step, keyword search still works but full-text search will be unavailable.

  **5. Serve the site:**
  ```
  bundle exec jekyll serve --host 0.0.0.0
  ```
  Starts a local server at `http://localhost:4000/`. The `--host 0.0.0.0` flag is needed when running inside Docker.

  **Important:** `jekyll serve` rebuilds the site before serving, which overwrites `_site/` and removes the Pagefind index. To preserve the search index, add `--skip-initial-build`:
  ```
  bundle exec jekyll serve --host 0.0.0.0 --skip-initial-build
  ```

#### npm shortcuts

  If you have npm available, `package.json` provides shortcuts that combine the steps above:

  | Command | What it does |
  |---------|-------------|
  | `npm run fetch` | Step 1: clone/update tutorial repos + preprocess + generate data |
  | `npm run preprocess` | Step 2: preprocess tutorial markdown |
  | `npm run build` | Steps 2+3+4: preprocess + Jekyll build + Pagefind indexing |
  | `npm run build:quick` | Steps 2+3: preprocess + Jekyll build (no search indexing) |
  | `npm run serve:indexed` | Steps 2+3+4+5: full build + serve with full-text search |
  | `npm run serve:quick` | Steps 2+3+5: quick build + serve (no full-text search) |
  | `npm run index` | Step 4 only: run Pagefind indexing on existing `_site/` |
  | `npm run serve` | Step 5 only: start Jekyll dev server (no build) |

  Common workflows:
  ```
  # Tutorials already present locally -- build and serve with search
  npm run serve:indexed

  # Fetch tutorials from GitHub first, then build and serve
  npm run fetch && npm run serve:indexed

  # Quick iteration -- no search indexing
  npm run serve:quick
  ```

  See [Building a local copy of the site](https://taming-the-beast.github.io/contribute/Building-a-local-copy-of-the-site/) for more information.


## License

  All source code in this repository, consisting of files with extensions `.html`, `.css`, `.less`, `.rb` or `.js`, is freely available under an MIT license, unless otherwise noted within a file. 

  **The MIT License (MIT)**

  Copyright (c) 2016-2017 Louis du Plessis, 2013-2016 Trevor Bedford

  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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
