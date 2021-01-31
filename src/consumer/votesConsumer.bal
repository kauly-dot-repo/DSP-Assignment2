
import ballerinax/kafka;
//import ballerina/lang.'string;
import ballerina/log;
import ballerina/io;
import ballerina/kubernetes;
import ballerina/docker;


// type Count record{
//     String name;
//     int counter;
// }

//count to store number of votes per candidate
map<int> countVotes = {};

//Consumer 1
kafka:ConsumerConfiguration consConf = {
    bootstrapServers: "localhost:9092",
    groupId: "vote",

    topics: ["voting"],
    pollingIntervalInMillis: 1000, 
    //keyDeserializerType: kafka:DES_INT,
    //valueDeserializerType: kafka:DES_STRING,
    autoCommit: false
};



listener kafka:Listener cons = new (consConf);

@kubernetes:Deployment{
    image:"",
    name:""
}


@docker:Config{
    name: "votes-consumer",
    tag: "v1.0"
}


service kafka:Service on cons {
    remote function onConsumerRecord(kafka:Caller caller,
                                kafka:ConsumerRecord[] records) {
        foreach var kafkaRecord in records {
            processKafkaRecord(kafkaRecord);
        }

        var commitResult = caller->commit();

        if (commitResult is error) {
            log:printError("Error occurred while committing the " +
                "offsets for the consumer ", err = commitResult);
        }
    }
}

//processes when someone votes
function processKafkaRecord(kafka:ConsumerRecord kafkaRecord) {
    byte[] value = kafkaRecord.value;
    string|error candidateName = string:fromBytes(value);
    
    if (candidateName is string) {
        if(countVotes.hasKey(candidateName)){
            int count = <int>countVotes[candidateName] + 1;
            countVotes[candidateName] = count;
        } else {
            countVotes[candidateName] = 1;

        }
        io:println(countVotes);
    } else {
        log:printError("Invalid value type received");
    }
}
