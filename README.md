# wri.pe

https://wri.pe source code.

## Install

### requirements

- Ruby 2.0.0 and above
- Bundler
- JRE 1.6 and above (for Solr)
- Pow - http://pow.cx/


### set up

```
cp config/async-sample.yml config/async.yml
cp config/evernote-sample.yml config/evernote.yml
cp config/github-sample.yml config/github.yml
cp config/dropbox-sample.yml config/dropbox.yml
cp config/facebook-sample.yml config/facebook.yml
cp config/paperclip_feedbacks_s3-sample.yml config/paperclip_feedbacks_s3.yml
# edit above yaml files

bundle install
rake sunspot:solr:run
rake db:migrate
ln -s `pwd` ~/.pow/wri.pe
```


### run

```
open "http://wripe.dev/"
```

You can login with GitHub and Facebook.


### test

#### with PhantomJS

```
rake 
```

#### with Chrome

```
rake DRIVER=chrome
```

#### with Safari

```
rake DRIVER=safari
```

#### with Firefox

```
rake DRIVER=firefox
```

#### with Internet Explorer

windows側でselenium-serverとstone 10.0.0.3:57124 57124を起動

```
rake DRIVER=ie
```

