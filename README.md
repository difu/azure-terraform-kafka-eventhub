# azure-terraform-eventhub

Testbed to explore Azure Event Hub. This is a simple example of how to create an Azure Event Hub installation. It is meant to be a starting point and a step-by-step tutorial to become familiar with the Azure Event Hub service.

## Steps

1. **Prepare your environment, set your Azure subscription:**

    ```sh
    az login
    ```

    Remember the _subscription id_ (NOT the name).

    ```sh
    az account set --subscription "YOUR_SUBSCRIPTION_ID"
    ```

2. **Create a service principal to authenticate Terraform to manage Event Hub infrastructure:**

    ```sh
    az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID" --name "terraform_principal"
    ```

    This command will return all the necessary credentials to authenticate. It is recommended to set these values as environment variables rather than saving them in your Terraform configuration.

    Set the following environment variables. Be sure to update the variable values with the values Azure returned in the previous command.

    ```sh
    export ARM_CLIENT_ID="<APP_ID>"
    export ARM_CLIENT_SECRET="<PASSWORD>"
    export ARM_SUBSCRIPTION_ID="<YOUR_SUBSCRIPTION_ID>"
    export ARM_TENANT_ID="<TENANT_ID>"
    ```

    **Note:** You may write this in a file, but be sure to exclude this from version control!

3. **Run the usual Terraform commands:**

    ```sh
    terraform init
    terraform apply
    ```

    As the returned output contains sensitive information, you must explicitly output the value.

    ```sh
    terraform output eventhub_connection_string
    ```

    Use this output for the next step.

4. **Connect to Kafka endpoint:**

    Use _kcat_ as a simple command line client to produce or consume data over Kafka. First, create a config file and put in the information from the previous step:

    ```plaintext
    metadata.broker.list=mynamespace.servicebus.windows.net:9093
    security.protocol=SASL_SSL
    sasl.mechanisms=PLAIN
    sasl.username=$ConnectionString
    sasl.password=Endpoint=sb://mynamespace.servicebus.windows.net/;SharedAccessKeyName=XXXXXX;SharedAccessKey=XXXXXX
    ```

    Replace:
    - `metadata.broker.list` with your namespace FQDN (change 'mynamespace' to your namespace name)
    - `sasl.password` with your namespace's connection string.

    Point to this configuration file and export its absolute path stored in `KAFKACAT_CONFIG`:

    ```sh
    export KAFKACAT_CONFIG=/absolute/path/to/config
    ```

    Verify that all works properly by running:

    ```sh
    kcat -b difueventhubnamespace.servicebus.windows.net:9093 -L
    ```

    Note that `KAFKA_CONFIG` is deprecated. Rename `KAFKA_CONFIG` to `KCAT_CONFIG`. For example:

    ```sh
    % Reading configuration from file /home/user/azure-terraform-eventhub/kcat.config
    Metadata for all topics (from broker 0: sasl_ssl://difueventhubnamespace.servicebus.windows.net:9093/0):
    1 brokers:
    broker 0 at difueventhubnamespace.servicebus.windows.net:9093 (controller)
    1 topics:
    topic "difuexampleeventhub" with 2 partitions:
        partition 0, leader 0, replicas: , isrs: 
        partition 1, leader 0, replicas: , isrs: 
    ```

5. **Produce some messages:**

    ```sh
    for MESSAGE in 1 2 3 4; do
        echo "Welcome to Kafka, Message $MESSAGE" | kcat -b difueventhubnamespace.servicebus.windows.net:9093 -P -t difuexampleeventhub -H "header1=header value" -H "nullheader" -H "emptyheader=" -H "header1=duplicateIsOk"
    done
    ```

6. **Consume them:**

    ```sh
    kcat -C -b difueventhubnamespace.servicebus.windows.net:9093 -t difuexampleeventhub
    ```

    **Note:**

    When trying to use `kcat` on macOS, you might encounter several errors, particularly when consuming messages:

    ```plaintext
    % ERROR: Local: Broker transport failure: sasl_ssl://difueventhubnamespace.servicebus.windows.net:9093/0: Disconnected (after 67ms in state UP)
    % ERROR: Local: All broker connections are down: 1/1 brokers are down: terminating
    ```

    The Docker image works in such cases:

    ```sh
    docker run -it --rm --entrypoint /bin/sh edenhill/kcat:1.7.1
    ```