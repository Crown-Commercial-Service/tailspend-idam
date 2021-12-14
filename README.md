# Tail Spend Solution IDAM

[![Build Status](https://app.travis-ci.com/Crown-Commercial-Service/pmp-idam.svg?branch=develop)](https://app.travis-ci.com/Crown-Commercial-Service/tailspend-idam)
[![Maintainability](https://api.codeclimate.com/v1/badges/0cd357c324b2731fb1bc/maintainability)](https://codeclimate.com/github/Crown-Commercial-Service/tailspend-idam/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/0cd357c324b2731fb1bc/test_coverage)](https://codeclimate.com/github/Crown-Commercial-Service/tailspend-idam/test_coverage)

## Prerequisites

This README assumes you are using a MacBook. If you are using a different operating system you may need to take different steps to achive the same results but the prerequisites are likely to be the same or similar.


### Ruby
This is a Ruby on Rails application using ruby version `2.7.1`.
Ensure that, if you are using a ruby environment manager, the correct ruby version is being run in your development environment.

This project uses Ruby Gems so you will need to install bundler which can be done with:
```
gem install bundler
```


### Yarn
In order to either run the project you will need to install Yarn. This is a package manager for JavaScript and is used to install Node modules and you can install it with:
```
brew install yarn
```


### Docker
It will be explained later, but in order to test the application locally you will need to install an application on a 'Docker' container. Therefore you will need docker installed on your machine.


### Database
For this project, the application uses PostgreSQL. To install PostgreSQL run the following command:
```
brew install postgres
```
Once you have finished installing PostgreSQL, you will need to run the database server. This can be done using either:
```
pg_ctl -D /usr/local/var/postgres start
```
or
```
brew services start postgresql
```


## Initialising the project
For all the node packages you will need to run:
```
yarn install
```
Once this has completed successfully, the next step is to install the required ruby gems to run the project. This can be done with the following command:
```
bundle install
```

Finally you will need to setup and seed the database and this can be done using the following command:
```
bundle exec rake db:setup
```

As much of the project uses external APIs you will need a .env.local file to access these APIs. If there is an existing developer on the project then you can ask them for it. If not you should still add a .env.local and add the relevant variables as you go along.

There is no data that can be initialised but you will need to add your email domain to the `AllowedEmailDomain` model and some organisations to the Organisation. You can either create files and use the rake tasks found in `lib/tasks/allow_email_domain.rake` and `lib/tasks/organisations.rake` or add the data manually though the console.


## Environemnt variables
This project uses environment variables which you will need to add to your .env.local file in the application. Below is a list of some of the environment variables and where to find them:
- **COGNITO_CLIENT_ID** - Obtained from the "General settings > App clients" of the AWS Cognito User Pool
- **COGNITO_CLIENT_SECRET** - Obtained from the "General settings > App clients" of the AWS Cognito User Pool
- **COGNITO_USER_POOL_ID** - Obtained from the "General settings" of the AWS Cognito User Pool
- **COGNITO_AWS_REGION** - The AWS region the Cognito User Pool was created in
- **AWS_ACCESS_KEY** - The access key for the AWS environment
- **AWS_SECRET_KEY** - The secret key for the AWS environment
- **AUTH_USER_API_TOKEN** - The token for the authentication of a user when signing in
- **OFFICE_TEAM_GET_URL** - `http://localhost:8080`
- **MERCATEO_GET_URL** - `http://localhost:8080`

## Running the application
To run the application use:
```
bundle exec rails s
```
This will then run the rails server on localhost:3000 but you will need to do some more setup before you can fully use and test the application.


## Using the application in the development environment
### Running Keycloak in the Docker container
This application is an interim IDAM solution to allow users to log into the Tail Spend Solution service. This service is being hosted and maintained externally but it is using an application called Keycloak for its single-sign-on. Therefore you will need to run a local version of the application in a Docker container for development purposes. You may find this [document](https://www.keycloak.org/getting-started/getting-started-docker) helpful if this README is not sufficient.

To download and run the container, use the following command:
```
docker run --rm -p 8080:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=admin \
  -e DB_VENDOR=h2 \
  quay.io/keycloak/keycloak:11.0.2
```
This will get the Keycloak container running on localhost port 8080.


### Installing and using nrok
One feature of Keycloak is that it will only work with HTTPS requests which the rails app will not be able to do locally. This README shows how to use the ngrok application to get around this but other solutions are available.

You will first need to create a free account which can do using this [link](https://dashboard.ngrok.com/signup). You can then follow the instructions to download and set up the application. This command will get the application running in your terminal:
```
./ngrok http 3000     
```
This should return the following kind of output:
```
Session Status                online
Account                       Your Name (Plan: Free)
Version                       2.3.35
Region                        United States (us)
Web Interface                 http://127.0.0.1:4040
Forwarding                    http://5ed36d69a2e7.ngrok.io -> http://localhost:3000
Forwarding                    https://5ed36d69a2e7.ngrok.io -> http://localhost:3000  
```
The final URL displayed is the one you should use to run the application, in this case https://5ed36d69a2e7.ngrok.io.


### Setting up Keycloak
Now that the application is running on a HTTPS connection you can set up the Keycloak environment. if you go to `http://localhost:8080/` you should be presented with the ‘Welcome to Keycloak’ page. Navigate to the ‘Administration console’ and log in using the username ‘admin’ and password ‘admin’.

The first thing you need to do is create a new ‘realm’ which can be done by clicking the dropdown in the top left corner. Give it the name ‘ccs-realm'. Once you have given the realm a name you need to add a new ‘Identity-provider’. You asked select `OpenID Connect v1.0` as the ‘Identity-provider’ and then you can fill out the form. The fields you need to worry about in the form are as follows:

- Alias: name it ‘oidc-localhost’
- Authorization URL: this is the host of your application plus this URL: `api/v1/oauth2/authorize`. For example, in my setup it looked like `https://5ed36d69a2e7.ngrok.io/api/v1/oauth2/authorize`. Note that this value needs to be updated every time you start ngrok as the beginning id will change.
- Token URL: this is the host of your application plus this URL: `api/v1/oauth2/token`. For example, in my setup it looked like `https://5ed36d69a2e7.ngrok.io/api/v1/oauth2/token`. Note that this value needs to be updated every time you start ngrok as the id at the beginning will change.
- Client Authentication: You want to select 'Client secret sent as basic auth' from the drop down
- Client ID: this is the COGNITO_CLIENT_ID in your .env.local file
- Client Secret: this is the COGNITO_CLIENT_SECRET in your .env.local file


Once you have saved this you will need to add mappers. These are the three mappers you need to create:
| Name                      |     First Name     |      Last Name     |       Organisation       |
|:-------------------------:|:------------------:|:------------------:|:------------------------:|
| **Sync Mode Override**    | inherit            | inherit            | import                   |
| **Mapper Type**           | Attribute Importer | Attribute Importer | Attribute Importer       |
| **Claim**                 | name               | family_name        | custom:organisation_name |
| **User Attribute Name**   | firstName          | lastName           | organisation_name        |

Once you have done this your Keycloak setup should be complete.


### Using the application locally

Log out of Keycloak and you navigate to the URL of your realm which will be http://localhost:8080/auth/realms/YOUR_REALM_NAME/account. If you followed this README it will be http://localhost:8080/auth/realms/ccs-realm/account.

You should see `oidc-localhost` (the name of your 'Alias') on the right hand side which you can click on and it should take you to the sign in page. Here you can create an account or sign in within the rails application and, if successful, you should end up on the edit account page within Keycloak.

What you will probably find is that the first time you try to sign in, the application will hang. If it does this you just need to restart the rails server and get to the sign in page through your realm again.Running tests and checking code


## Running tests and checking code
### RSpec
At the time of writing this README, the application does not contain any unit tests, however the application is configured to use RSpec. If, in the future, unit test have been added then you can run a specific test with:
```
bundle exec rspec spec/..path_to_file../*.spec
```


### Rubocop
The project also uses rubocop which is a linter to make sure the code meets the required standards. the following command is one you may find very useful:
```
rubocop -a
```
Not only will this highlight all the issues, but it will also try to fix them as well.


### I18n
Most of the copy for the application is held within translation files. The following command will tell you the status of the translation file:
```
i18n-tasks health
```
If there are any issues that arise, you can follow the output to solve them. Another useful command is `i18n-tasks` as this will give you list of useful tasks that can be performed which may save you some work.
