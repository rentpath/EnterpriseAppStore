RentPath Mobile App Distribution Website
================================

This repo contains the source code for the RentPath mobile application distribution website.

Project Dependencies:
------------------------------

### RVM to Manager Rubies:
If you do not already have RVM installed, please install it at this time using the following command.
``` $ \curl -L https://get.rvm.io | bash -s stable ```

### Ruby 2.0.0:
Using RVM, install Ruby 2.0.0 using the following command.
``` $ rvm install 2.0.0 ```

### Bundler Gem:
If you do not have Bundler installed, please install using the following command.
``` $ gem install bundler ```

### Please create a database.yml file using the example
There is an example database.yml file called database.yml.example in config/. Please rename it to database.yml.

### Imagemagick:
This project utilizes the Paperclip gem for file uploads. When uploading images for Projects or new App Versions, the images will need to be resized. To do this Paperclip utilizes framework called Imagemagick. To install Imagemagick on your machine, please follow the following instructions and do not skip any steps or the installation of the rmagick gem will fail when trying to run "Bundle Install: later.

```
$ brew remove imagemagick
$ brew install imagemagick --disable-openmp --build-from-source

$ cd /usr/local/Cellar/imagemagick/6.8.0-10/lib
$ ln -s libMagick++-Q16.7.dylib   libMagick++.dylib
$ ln -s libMagickCore-Q16.7.dylib libMagickCore.dylib
$ ln -s libMagickWand-Q16.7.dylib libMagickWand.dylib
```

### PostgreSQL:
This project also utilizes PostgreSQL as it's data store. To install PostreSQL simply download it here: http://www.enterprisedb.com/postgresql-924-installers-osx&ls=Crossover&type=Crossover and run the installer. When prompted to choose a port, please use the default port of "5432". When prompted to choose a database password please use "pass1234". This is what's setup currently in the config/database.yml. If you choose a different password that's fine, but you'll need to make the necessary changes during the Setup process in the following section.

### Amazon S3:
an S3 bucket is used to store all of the uploaded images, ipa's, and plist's. In order for you to be able to run the app locally and create new projects and/or app versions, you'll need to set up the following environment variables so the files can be uploaded to S3.

AWS_ACCESS_KEY_ID: AKIAIBZ32CFZLHHBKOMQ
AWS_BUCKET: rentpath_app_store_bucket
AWS_SECRET_ACCESS_KEY: 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

Project Setup:
-------------------

- Download the source code
- Install required dependencies listed earlier in the README
- $ cd ~/sources/enterprise_app_store
- If you chose to use a different password for your local PostgreSQL install, you'll need to update the config/database.yml with your specific password at this time.
- $ bundle install (If you are having troubles with the rmagick gem, please make sure you've read the Project Dependencies section above)
- $ rake db:create
- $ rake db:migrate
- At this point you should be ready to run the application.
