import json
import requests

def handler(event, context):
    api_key = "47e18dc03168f343d6d537550a46c83c"
    city = "London"
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}"

    response = requests.get(url)
    data = response.json()

    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }
