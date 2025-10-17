# Taming the BEAST website

Taming the BEAST is a platform for collating a comprehensive and cohesive set of BEAST 2 tutorials in one location, providing researchers the resources necessary to learn how to perform analyses in BEAST 2. This GitHub repository stores the source code for the Taming the BEAST website. The site is based on Trevor Bedford's lab website ([http://bedford.io](http://bedford.io)).

## Build site

You can choose to set up a build environment locally or use a container image. Building and publishing with a container image can also be done directly on GitHub. You may also first use the testing set up to check any changes.

### Build and test within GitHub

#### Build and publish TESTING version of the site within GitHub

  All changes should be made to [blotter_test](https://github.com/Taming-the-BEAST/blotter_test) repository first:
  - sync [blotter_test](https://github.com/Taming-the-BEAST/blotter_test) with [blotter](https://github.com/Taming-the-BEAST/blotter)
  - push changes to [blotter_test](https://github.com/Taming-the-BEAST/blotter_test)
  - publish testing version of the website:
    - go to the https://github.com/Taming-the-BEAST/web-testing repository
    - select `Actions` tab
    - select `Publish TTB website` action
    - click `Run workflow` and wait for it to finish.
  
  Hopefully, you can see your changes now on the [taming-the-beast.org/web-testing/](taming-the-beast.org/web-testing/)  

#### Build and publish PRODUCTION version of the site within GitHub   

  If you are ready to publish the public version of the website, repeat the same steps as above but from the https://github.com/Taming-the-BEAST/Taming-the-BEAST.github.io repository:
  - go to the [https://github.com/Taming-the-BEAST/web-testing](https://github.com/Taming-the-BEAST/Taming-the-BEAST.github.io) repository
  - select `Actions` tab
  - select `Publish TTB website` action
  - click `Run workflow` and wait for it to finish. 
  
  You should see the changes on the https://taming-the-beast.org website.

### Build site locally

#### Using a container

  You will have to authenticate to GitHub container registry using your personal access token (YOUR_PA). 
  You need to have repo and read/write packages permissions for the token.
  ```
  export CR_PAT=YOUR_PA
  echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
  ```
  Then you can pull the docker image: 
  ```
  docker pull ghcr.io/taming-the-beast/ttb-web-build-env:latest
  ```
  Using this image you can start a new container. To complete all steps successfully you may need to use the run options:
  ```
  docker run -it --env  GITHUB_TOKEN=YOUR_PA -p 4000:4000 ghcr.io/taming-the-beast/ttb-web-build-env sh
  ```
  
  The first option is required to avoid API request limits and the second one allows you to view the built site on your local machine (the port 4000 on the container is exposed to port 4000 on your local machine).
  
  Withing the container you can build as you would on your local machine (see below), but you should skip step 2 as all required dependencies are installed.
  At step 4 you may need to supply the option `--host=0.0.0.0` to be able to view the site.

#### Build directly on local machine

  1. To build the website locally, clone the repo with:
  
  ```
  git clone https://github.com/Taming-the-BEAST/blotter.git
  ```
  
  2. Then install necessary Ruby dependencies by running `bundle install` from within the `blotter` directory.
     
  3. After this, the site can be be built with:
  ```
  bundle exec jekyll build
  ```
  
  - If you wish to build with tutorials, preprocessing scripts are necessary to clone tutorial repos and update Jekyll metadata. To do this, execute the following before the build command:
    
    ```
    ruby _scripts/update-and-preprocess.rb
    ```
  - If you wish to skip tutorials (much faster), export the following env variable, before the build command:
    ```
    export JEKYLL_ENV=skip_tuts
    ```
  
  4. To view the site, run `bundle exec jekyll serve --host=0.0.0.0` and point a browser to `http://localhost:4000/`. Option `--host=0.0.0.0` may not be needed, depending on your setup.  More information on Jekyll can be found [here](http://jekyllrb.com/).
  
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
