# RSPEC

## Description
This software has a suite of spec tests in the 'spec' folder.

## Requirements
Update the schema with:
    bin/rake db:migrate RAILS_ENV=test

Please prepare the correct folder structure for the test environment:


    |--muscat /
    |--|-solr /
    |--|-|-test /
    |--|-|-|-data /
    |--|-|-|-core.properties

The schema will be loaded into a mysql database; all objects are created by
FactoryBot during the suite. Please be aware, that you might have to edit your
database settings (database.yml).

## Requirements
For headless chrome: Chrome 59+ and ChromeDriver installed.
    CHROME_DRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`
    wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/
    unzip chromedriver_linux64.zip
    sudo install chromedriver /usr/local/bin
    apt install gconf-service libgconf-2-4 libnspr4 libnss3 libpango1.0-0 libappindicator1 libcurl3
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpgk -i google-chrome-stable_current_amd64.deb

This connects to the following sunspot-solr instance (see config/solr.yml):
    test: &test
      url: <%= ENV['SOLR_URL'] || "http://127.0.0.1:8981/solr/test" %>

## Workflow
Before starting the suite solr server should be initialized in the test
environment (In case the server is running in another environment, stop it
first!):

    RAILS_ENV=test bin/rake sunspot:solr:start

To execute the full suite call:

    bundle exec rspec -fd

After finishing the sunspot session could be stopped with:

    RAILS_ENV=test bin/rake sunspot:solr:stop

## Sunspot

Some examples are relying on a clean Sunspot:Solr index. It should be switched
on by setting "solr: true" as an argument, eg:

    RSpec.describe Admin::SourcesController, :type => :controller, solr: true do 
    end

