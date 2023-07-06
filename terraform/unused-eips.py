import boto3
import os
client = boto3.client('ec2')
sesClient = boto3.client('ses')

SOURCE_EMAIL = os.environ['SOURCE_EMAIL']
DEST_EMAIL = os.environ['DEST_EMAIL']

def lambda_handler(event,context):
	response = client.describe_addresses()
	eips = []
	for eip in response['Addresses']:
		if 'InstanceId' not in eip:
			eips.append(eip['PublicIp'])
			

	if eips:
		sesClient.send_email(
			Source = SOURCE_EMAIL,
			Destination=(
				'ToAdresses':[
					DEST_EMAIL
				]
			},
			Message={
				'Subject': {
					'Data': 'Unused EIPS',
					'Charset': 'UTF-8'
				},
				'Body': {
					'Text': {
						'Data': str(eips),
						'Charset': 'UTF-8'
					}
				}
			}
		)