read -p "Domain: " D
printf "ENVIRONMENT = local\nBASE_URL_SCHEMA = http\nBASE_URL = 127.0.0.1:8000\n" > ios/Config/Config.Development.xcconfig
printf "ENVIRONMENT = production\nBASE_URL_SCHEMA = https\nBASE_URL = %s\n" "$D" > ios/Config/Config.Production.xcconfig
echo "Done: ios/Config/Config.Development.xcconfig, ios/Config/Config.Production.xcconfig"