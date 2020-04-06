Some helpful lambda tricks

```
pip install --target ./package <PACKAGE_NAME>
cd package/
zip -r9 ${OLDPWD}/function.zip .
cd $OLDPWD
zip -g function.zip lambda_function.py
aws lambda update-function-code --function-name createUser --zip-file fileb://function.zip

```
