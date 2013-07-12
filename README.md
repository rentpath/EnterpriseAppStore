{\rtf1\ansi\ansicpg1252\cocoartf1187\cocoasubrtf390
{\fonttbl\f0\fswiss\fcharset0 Helvetica;\f1\fmodern\fcharset0 Courier;\f2\fmodern\fcharset0 CourierNewPSMT;
}
{\colortbl;\red255\green255\blue255;\red19\green8\blue105;\red246\green246\blue246;\red96\green96\blue96;
\red15\green112\blue3;}
\margl1440\margr1440\vieww22180\viewh23900\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural

\f0\fs24 \cf0 RentPath Mobile App Distribution Website\
================================\
\
This repo contains the source code for the RentPath mobile application distribution website.\
\
Project Dependencies:\
------------------------------\
\
### RVM to Manager Rubies:\
If you do not already have RVM installed, please install it at this time using the following command.\
\pard\pardeftab720

\f1 \cf0 ``` $ \\curl -L https://get.rvm.io | bash -s stable ```\
\
### Ruby 2.0.0:\
Using RVM, install Ruby 2.0.0 using the following command.\
``` $ rvm install 2.0.0 ```\
\
### Bundler Gem:\
If you do not have Bundler installed, please install using the following command.\
``` $ gem install bundler ```
\f0 \
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural
\cf0 \
### Imagemagick:\
This project utilizes the Paperclip gem for file uploads. When uploading images for Projects or new App Versions, the images will need to be resized. To do this Paperclip utilizes framework called Imagemagick. To install Imagemagick on your machine, please follow the following instructions and do not skip any steps or the installation of the rmagick gem will fail when trying to run "Bundle Install: later.\
\
```\
\pard\pardeftab720

\f2\fs26 \cf2 \cb3 $ \cf4 brew remove imagemagick\
\cf2 $ \cf4 brew install imagemagick --disable-openmp --build-from-source\
\
\cf2 $ \cf5 cd\cf4  /usr/local/Cellar/imagemagick/6.8.0-10/lib\
\cf2 $ \cf4 ln -s libMagick++-Q16.7.dylib   libMagick++.dylib\
\cf2 $ \cf4 ln -s libMagickCore-Q16.7.dylib libMagickCore.dylib\
\cf2 $ \cf4 ln -s libMagickWand-Q16.7.dylib libMagickWand.dylib
\f0\fs24 \cf0 \cb1 \
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural
\cf0 ```\
\
### PostgreSQL:\
This project also utilizes PostgreSQL as it's data store. To install PostreSQL simply download it here: {\field{\*\fldinst{HYPERLINK "http://www.enterprisedb.com/postgresql-924-installers-osx&ls=Crossover&type=Crossover"}}{\fldrslt http://www.enterprisedb.com/postgresql-924-installers-osx&ls=Crossover&type=Crossover}} and run the installer. When prompted to choose a port, please use the default port of "5432". When prompted to choose a database password please use "pass1234". This is what's setup currently in the config/database.yml. If you choose a different password that's fine, but you'll need to make the necessary changes during the Setup process in the following section.\
\
### Amazon S3:\
an S3 bucket is used to store all of the uploaded images, ipa's, and plist's. In order for you to be able to run the app locally and create new projects and/or app versions, you'll need to set up the following environment variables so the files can be uploaded to S3.\
\
AWS_ACCESS_KEY_ID: AKIAIBZ32CFZLHHBKOMQ\
AWS_BUCKET: rentpath_app_store_bucket\
AWS_SECRET_ACCESS_KEY: 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\
\
Project Setup:\
-------------------\
\
- Download the source code\
- Install required dependencies listed earlier in the README\
- $ cd ~/sources/EnterpriseAppStore\
- If you chose to use a different password for your local PostgreSQL install, you'll need to update the config/database.yml with your specific password at this time.\
- $ bundle install (If you are having troubles with the rmagick gem, please make sure you've read the Project Dependencies section above)\
- $ rake db:create\
- $ rake db:migrate\
- At this point you should be ready to run the application.}