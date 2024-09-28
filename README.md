# azure-terraform-eventhub
Testbed to explore Azure Event Hub 

This is a simple example of how you can create an Azure Event Hub installation.
It is meant to be a starting point and a step-by-step tutorial to become familiar with the Azure Event Hub service.

 - Prepare your environment, set your Azure subscription.

```shell
az login
```
Remember the _subscription id_ (NOT the name).

```shell
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

 - Create a service principal to authenticate terraform to manage event hub infrastructure

```shell
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID" --name "terraform_principal"
```
This command will return all the necessary credentials to authenticate. It is recommended setting these values as
environment variables rather than saving them in your Terraform configuration.
Set the following environment variables. Be sure to update the variable values with the values Azure returned
in the previous command.

```shell
export ARM_CLIENT_ID="<APP_ID>"
export ARM_CLIENT_SECRET="<PASSWORD"
export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<TENANT_ID>"
```

__Note:__ you may write that in a file, but be sure to exclude this from version control!

After that run the usual _terraform_ commands.

```shell
terraform init
terraform apply
```

As the returned output contains sensitive information, you must explicitly output the value. 

```shell
terraform output eventhub_connection_string
```

Use this output for the next step.

 - Connect to Kafka endpoint

Use _kcat_ as a simple command line client to produce or consume data over Kafka. 
First, create a config file and put in the information from the previous step

```shell
metadata.broker.list=mynamespace.servicebus.windows.net:9093
security.protocol=SASL_SSL
sasl.mechanisms=PLAIN
sasl.username=$ConnectionString
sasl.password=Endpoint=sb://mynamespace.servicebus.windows.net/;SharedAccessKeyName=XXXXXX;SharedAccessKey=XXXXXX
# Replace
# - 'metadata.broker.list' with your namespace FQDN (change 'mynamespace' to your namespace name)
# - 'sasl.password' with your namespace's connection string 
```

Point to this configuration file and export its absolute path stored in $KAFKACAT_CONFIG

```shell
    export KAFKACAT_CONFIG=/absolute/path/to/config
```

Verify that all works properly by running

```shell
kcat -b difueventhubnamespace.servicebus.windows.net:9093 -L
% KAFKA_CONFIG is deprecated!
% Rename KAFKA_CONFIG to KCAT_CONFIG
% Reading configuration from file /home/difu/Programming/azure-terraform-eventhub/kcat.config
Metadata for all topics (from broker 0: sasl_ssl://difueventhubnamespace.servicebus.windows.net:9093/0):
 1 brokers:
  broker 0 at difueventhubnamespace.servicebus.windows.net:9093 (controller)
 1 topics:
  topic "difuexampleeventhub" with 2 partitions:
    partition 0, leader 0, replicas: , isrs: 
    partition 1, leader 0, replicas: , isrs: 

```

Produce some messages:

```shell
for MESSAGE in 1 2 3 4; do echo "Welcome to Dirks Kafka, Message $MESSAGE" | kcat -b difueventhubnamespace.servicebus.windows.net:9093 -P -t difuexampleeventhub -H "header1=header value" -H "nullheader" -H "emptyheader=" -H "header1=duplicateIsOk"; done
```

Consume them:

```shell
kcat -C  -b difueventhubnamespace.servicebus.windows.net:9093 -t difuexampleeventhub
```