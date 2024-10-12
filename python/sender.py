import asyncio

from azure.eventhub import EventData, TransportType
from azure.eventhub.aio import EventHubProducerClient
from azure.identity.aio import DefaultAzureCredential


EVENT_HUB_FULLY_QUALIFIED_NAMESPACE = "[YOUR EVENT HUB NAMESPACE CONNECT_STRING]"
EVENT_HUB_NAME = "difuexampleeventhub"

credential = DefaultAzureCredential()

async def run():
    """
    :return: Sends a batch of events to an Azure Event Hub. The function creates an EventHubProducerClient,
             constructs an event batch, adds events to this batch, sends the batch to the Event Hub, and then closes
             the credential.
    """
    producer = EventHubProducerClient(
        fully_qualified_namespace=EVENT_HUB_FULLY_QUALIFIED_NAMESPACE,
        eventhub_name=EVENT_HUB_NAME,
        credential=credential,
    )
    async with producer:
        event_data_batch = await producer.create_batch()

        event_data_batch.add(EventData("1st event"))
        event_data_batch.add(EventData("2nd event"))
        event_data_batch.add(EventData("3rd event"))
        event_data_batch.add(EventData("and some other event"))

        await producer.send_batch(event_data_batch)

        await credential.close()

asyncio.run(run())