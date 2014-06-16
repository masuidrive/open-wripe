# wri.pe

https://wri.pe source code.

## Install

### requirements

- Ruby 2.0.0 and above
- Bundler
- JRE 1.6 and above (for Solr)
- Pow - http://pow.cx/

### optional requirenments

- Powder - https://github.com/rodreegez/powder

### set up

```
cp config/async-sample.yml config/async.yml
cp config/evernote-sample.yml config/evernote.yml
cp config/github-sample.yml config/github.yml
cp config/dropbox-sample.yml config/dropbox.yml
cp config/facebook-sample.yml config/facebook.yml
cp config/paperclip_feedbacks_s3-sample.yml config/paperclip_feedbacks_s3.yml
# edit above yaml files

bundle install --path vendor/bundle
bundle exec rake sunspot:solr:run
bundle exec rake db:migrate
ln -s `pwd` ~/.pow/wripe
```


### run

You can login with GitHub or Facebook.

#### except Chrome

```
bundle exec rake sunspot:solr:run # in case of stopping solr
open "http://wripe.dev/"
```

#### with Chrome

```
bundle exec rake sunspot:solr:run # in case of stopping solr
bundle exec rails s
open "http://lvh.me:3000/"
```


### test

#### with PhantomJS

```
bundle exec rake
```

#### with Chrome

```
bundle exec rake DRIVER=chrome
```

#### with Safari

```
bundle exec rake DRIVER=safari
```

#### with Firefox

```
bundle exec rake DRIVER=firefox
```

#### with Internet Explorer

windows側でselenium-serverとstone 10.0.0.3:57124 57124を起動

```
bundle exec rake DRIVER=ie
```
