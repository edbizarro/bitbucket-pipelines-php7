# Bitbucket Pipelines PHP 7.1 image (Deprecated)

## This image is no longer necessary
> Bitbucket Pipelines now supports services! See (https://confluence.atlassian.com/bitbucket/test-with-databases-in-bitbucket-pipelines-856697462.html)

You can continue using all the features (except for the mysql part) whith my base image https://github.com/edbizarro/gitlab-ci-pipeline-php/

[![](https://images.microbadger.com/badges/version/edbizarro/bitbucket-pipelines-php7.svg)](https://microbadger.com/images/edbizarro/bitbucket-pipelines-php7 "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/edbizarro/bitbucket-pipelines-php7.svg)](https://microbadger.com/images/edbizarro/bitbucket-pipelines-php7 "Get your own image badge on microbadger.com")

[![forthebadge](http://forthebadge.com/images/badges/fuck-it-ship-it.svg)](http://forthebadge.com)

## Based on [Official PHP image](https://hub.docker.com/_/php/)

### Packages installed

- PHP 7.1 with `mcrypt`, `mongod`, `xdebug`, `zip`, `xml`, `mbstring`, `curl`, `json`, `imap`, `mysql`, `iconv`, `gd`, `pdo_mysql`, `opcache`, `intl`. `zip`, `bcmath` and `tokenizer`
- [Composer](https://getcomposer.org/)
- Node 9.x / NPM / [Yarn](yarnpkg.com)
- Mysql 5.7

#### Why install MySQL in the image?

The Bitbucket pipeline don't support MySQL as service, like many others solutions out there (like Gitlab), so, the solution is to install MySQL and start the service in pipeline run

## `bitbucket-pipelines.yml` example

```YAML
image: edbizarro/bitbucket-pipelines-php7
pipelines:
  default:
    - step:
        script:
          - sudo service mysql start # We need this here because bitbucket don't have MySQL service :/
          - mysql -h localhost -u root -proot -e "CREATE DATABASE test;"
          - composer install --no-interaction --no-progress --prefer-dist
          - yarn
          - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
```
