import json
import psycopg2

def lambda_handler(event, context):
    # TODO implement
    device_apn_token = event['queryStringParameters']['device_apn_token']
    device_registration_token = event['queryStringParameters']['device_registration_token']
    
    connection = psycopg2.connect(user = "<HANSEL_CONFIG_DB_USER>",  
                              password = "<HANSEL_CONFIG_DB_PASSWORD>",
                              host = "<HANSEL_CONFIG_DB_HOST>",
                              port = "5432",
                              database = "covid")
    cursor = connection.cursor()
    cursor.execute("insert into users(device_apn_token , device_registration_token ) values("+device_apn_token+","+device_registration_token+") returning user_id;")
    record = cursor.fetchone()
    print("You are connected to - ", record,"\n")
    
    
    return {
        'statusCode': 200,
        'body': json.dumps(record[0])
    }
