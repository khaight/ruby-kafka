describe "Producer API", functional: true do
  let!(:topic) { create_random_topic(num_partitions: 3) }

  example "listing all topics in the cluster" do
    expect(kafka.topics).to include topic

    topic2 = create_random_topic(num_partitions: 1)

    expect(kafka.topics).to include(topic, topic2)
  end

  example "fetching the partition count for a topic" do
    expect(kafka.partitions_for(topic)).to eq 3
  end

  example "fetching the partition count for a topic that doesn't yet exist" do
    topic = "unknown-topic-#{rand(1000)}"

    expect { kafka.partitions_for(topic) }.to raise_exception(Kafka::LeaderNotAvailable)

    # Eventually the call should succeed.
    expect {
      10.times { kafka.partitions_for(topic) rescue nil }
    }.not_to raise_exception

    expect(kafka.partitions_for(topic)).to be > 0
  end

  example "delivering a message to a topic" do
    kafka.deliver_message("yolo", topic: topic, key: "xoxo", partition: 0)

    message = kafka.fetch_messages(topic: topic, partition: 0, offset: 0).first

    expect(message.value).to eq "yolo"
    expect(message.key).to eq "xoxo"
  end

  example "enumerating the messages in a topic" do
    values = (1..10).to_a

    values.each do |value|
      kafka.deliver_message(value.to_s, topic: topic)
    end

    kafka.each_message(topic: topic) do |message|
      value = Integer(message.value)
      values.delete(value)

      if message.value == "5"
        values << 666
        kafka.deliver_message("666", topic: topic)
      end

      break if values.empty?
    end

    expect(values).to eq []
  end

  example "getting the last offset for a topic partition" do
    topic = create_random_topic(num_partitions: 1, num_replicas: 1)

    kafka.deliver_message("hello", topic: topic, partition: 0)
    kafka.deliver_message("world", topic: topic, partition: 0)

    offset = kafka.last_offset_for(topic, 0)

    expect(offset).to eq 1
  end

  example "fetch a list of consumer groups in a cluster" do
    producer = kafka.producer
    producer.produce(1.to_s, topic: topic, partition_key: 1.to_s)
    producer.deliver_messages


    consumer_1 = kafka.consumer(group_id: "consumer_1")
    consumer_1.subscribe(topic)
    c1 = Thread.new do
      consumer_1.each_message do |message|
      end
    end

    consumer_2 = kafka.consumer(group_id: "consumer_2")
    consumer_2.subscribe(topic)
    c2 = Thread.new do
     consumer_2.each_message do |message|
     end
    end

    sleep(10) # give some time for the consumers to register
    expect(kafka.list_groups.length).to eq 2

    consumer_1.stop
    consumer_2.stop
  end

  example "fetch a description of of a specific group in a cluster" do
    producer = kafka.producer
    producer.produce(1.to_s, topic: topic, partition_key: 1.to_s)
    producer.deliver_messages


    consumer_1 = kafka.consumer(group_id: "consumer_1")
    consumer_1.subscribe(topic)
    c1 = Thread.new do
      consumer_1.each_message do |message|
      end
    end

    consumer_2 = kafka.consumer(group_id: "consumer_2")
    consumer_2.subscribe(topic)
    c2 = Thread.new do
     consumer_2.each_message do |message|
     end
    end

    sleep(10) # give some time for the consumers to register
    expect(kafka.describe_groups(['consumer_1', 'consumer_2']).length).to eq 2

    consumer_1.stop
    consumer_2.stop
  end
end
