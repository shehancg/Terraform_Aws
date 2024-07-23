#!/bin/bash

# Define variables
PACKAGE_DIR="package"
ZIP_FILE="function.zip"
REQUIREMENTS_FILE="requirements.txt"
LAMBDA_FUNCTION_FILE="lambda_function.py"

# Clean up previous builds
rm -rf $PACKAGE_DIR $ZIP_FILE

# Create package directory
mkdir -p $PACKAGE_DIR

# Install dependencies into package directory
pip install -r $REQUIREMENTS_FILE -t $PACKAGE_DIR

# Copy Lambda function code into package directory
cp $LAMBDA_FUNCTION_FILE $PACKAGE_DIR

# Create zip file from package directory contents
cd $PACKAGE_DIR
zip -r ../$ZIP_FILE .
cd ..

# Output the result
echo "Created $ZIP_FILE with the following contents:"
unzip -l $ZIP_FILE

