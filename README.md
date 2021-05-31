git clone https://github.com/FallenHoot/azure_api_management.git
cd azure_api_management

# Create Azure App Service (Free)
bash setup.sh

# Create & Configure API Management
az apim create --name $APIM --resource-group $RG --location $location --publisher-name $NAME --publisher-email ITOperations@donotreplydemo.com --sku-name Consumption

URL=https:// + $apiappname + .azurewebsites.net/swagger/v1/swagger.json
az apim api import --path '/apis' --resource-group $RG --service-name $APIM --display-name $APIM --specification-format OpenApi --specification-url $URL


az group delete --name myResourceGroup