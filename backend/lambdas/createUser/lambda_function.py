import json
import psycopg2

def lambda_handler(event, context):
    # TODO implement
    device_apn_token = event['queryStringParameters']['device_apn_token']
    device_registration_token = event['queryStringParameters']['device_registration_token']
    
    connection = psycopg2.connect(user = "<db_user>",  
                              password = "<db_password>",
                              host = "<db_host>",
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
