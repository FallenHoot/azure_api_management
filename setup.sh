#!/bin/bash
# Name of the project
NAME=demo

printf "Grabbing vars ... (1/9)\n\n"
# Var you can change if you want
location=westeurope
let randomNum=$RANDOM*$RANDOM
APIM=apim-$NAME-$randomNum
apiappname=AmazingAPIcompany$(openssl rand -hex 5)
RG=rg-$randomNum-apim

printf "Replacing Naming convention ... (2/9)\n\n"
# Replaces naming to reflect whatever name you decide using the following var $NAME
REPLACE=AmazingAPIcompany
find . -type f -exec sed -e s/$REPLACE/$NAME/g -i '{}' ';'
find . -depth -name "*$REPLACE*" -print0|while IFS= read -rd '' f; do mv -i "$f" "$(echo "$f"|sed -r "s/(.*)"$REPLACE"/\1"$NAME"/")"; done

# Create Azure env
az group create --name $RG --location $location 

printf "Setting username and password for Git ... (3/9)\n\n"

GIT_USERNAME=gitName$Random
GIT_EMAIL=a@b.c

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

# Create App Service plan
PLAN_NAME=myPlan


printf "\nCreating App Service plan in FREE tier ... (4/9)\n\n"
az appservice plan create --name $apiappname --resource-group $RG --sku FREE --location $location --verbose

printf "\nCreating API App ... (3/7)\n\n"
az webapp create --name $apiappname --resource-group $RG --plan $apiappname --deployment-local-git --verbose


printf "\nSetting the account-level deployment credentials ...(5/9)\n\n"
DEPLOY_USER="myName1$(openssl rand -hex 5)"
DEPLOY_PASSWORD="Pw1$(openssl rand -hex 10)"

az webapp deployment user set --user-name $DEPLOY_USER --password $DEPLOY_PASSWORD --verbose


GIT_URL="https://$DEPLOY_USER@$apiappname.scm.azurewebsites.net/$apiappname.git"

# Create Web App with local-git deploy
REMOTE_NAME=production

# Set remote on src
printf "\nSetting Git remote...(6/9)\n\n"
git remote add $REMOTE_NAME $GIT_URL

printf "\nGit add...(7/9)\n\n"
git add .
git commit -m "initial revision"

printf "\nGit push... (8/9)\n\n"
# printf "When prompted for a password enter this: $DEPLOY_PASSWORD\n"
# git push --set-upstream $REMOTE_NAME master
git push "https://$DEPLOY_USER:$DEPLOY_PASSWORD@$apiappname.scm.azurewebsites.net/$apiappname.git"


printf "Setup complete!\n\n"

printf "***********************    IMPORTANT INFO  *********************\n\n"

printf "Swagger URL: https://$apiappname.azurewebsites.net/swagger\n"

printf "Swagger JSON URL: https://$apiappname.azurewebsites.net/swagger/v1/swagger.json\n\n"

printf "\nCreate & Configure API Management... (9/9)\n\n"
# Create & Configure API Management
az apim create --name $APIM --resource-group $RG --location $location --publisher-name $NAME --publisher-email ITOperations@donotreplydemo.com --sku-name Consumption

URL=https://$apiappname.azurewebsites.net/swagger/v1/swagger.json
az apim api import --path '/apis' --resource-group $RG --service-name $APIM --display-name $APIM --specification-format OpenApi --specification-url $URL