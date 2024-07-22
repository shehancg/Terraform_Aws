Hello there this repo details on how to create a lambda function and connecting a event bridge to it trigger automatically

1. First we Add the providers.

2. Then we add the access keys for the aws account

3. Creaet an IAM role for the lambda function

4. Attaching a IAM policy for th role. 

5. Create a python function to deploy to the lambda function

6. Zip the .py function so we can attach it to the lambda function later 

7. define the lambda funcntion with the proper parameters and attach the zip using the following way 
source_code_hash = filebase64sha256("lambda_function.zip")

8. creating the eventbridge with neccessary schedule

9. Creating the target for the event bridge

10. giving permision for eventbridge to invoke lambda func