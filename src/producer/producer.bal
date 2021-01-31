
import ballerinax/kafka;
import ballerina/graphql;
import ballerina/io;
import ballerina/kubernetes;
import ballerina/docker;
//import ballerina/docker;

//This is both the graphQL api and producer -- producer send messages to kafka
 
// @docker:Config {
//   name:"register_candi",
//   tag:"v1.0"
// }
// @kubernetes:Deployment { image:"consumer-service", name:"kafka-consumer" }

//Producer for registering candidates
kafka:ProducerConfiguration Candidate_Register = {
	bootstrapServers: "localhost:9092",
	clientId: "register-candidate",
	acks: "all",
	retryCount: 3
//	valueSerializerType: kafka:SER_STRING,
//	keySerializerType: kafka:SER_INT
};

//Producer for voting
kafka:ProducerConfiguration vote = {
	bootstrapServers: "localhost:9092",
	clientId: "vote",
	acks: "all",
	retryCount: 3
//	valueSerializerType: kafka:SER_STRING,
//	keySerializerType: kafka:SER_INT
};


//Prodcuer for registering voters
kafka:ProducerConfiguration register_voter = {
	bootstrapServers: "localhost:9092",
	clientId: "register-voter",
	acks: "all",
	retryCount: 3
//	valueSerializerType: kafka:SER_STRING,
//	keySerializerType: kafka:SER_INT
};


//information storage - local store
map<json> registered_candidate_voters ={};
map<json> register_vote ={};
map<json> accepted_vote ={};//create a file that stores all the


kafka:Producer prod =checkpanic new (Candidate_Register);
kafka:Producer vote_producer =checkpanic new (vote);
kafka:Producer vote_register_prod =checkpanic new (register_voter);

@kubernetes:Deployment{
    image:"",
    name:""
}

@docker:Config{
    name: "producer",
    tag: "v1.0"
}

//graphql service listening 9090
service graphql:Service /graphql on new graphql:Listener(9090) {
 //register candidate
    resource function get register_candidate(string name,int id,string department) returns string {
            Candidate candidate ={name,id,department};
            //using the id number as an index in the array
            registered_candidate_voters[id.toString()] = {name:name,vID:id,party:department};
            byte[] serialisedMsg = candidate.toString().toBytes();

//call producer to send messages to a topic "candidateReg" 
             checkpanic prod->sendProducerRecord({
                                    topic: "candidateReg",
                                    value: serialisedMsg });

            //  checkpanic prod->flushRecords();\
            io:println(registered_candidate_voters);
        return "Candidate registered succesfully : " + name;
    }
    //vote-------------------------------------------------------------------
     resource function get vote(int voterID,int candidateID) returns string {
            
        //    //check if the details are correct
            if (register_vote.hasKey(voterID.toString()) && registered_candidate_voters.hasKey(candidateID.toString()) ){
                  io:println("vote is sucess");
                  accepted_vote[voterID.toString()] ={voterID,candidateID};
                 byte[] serialisedMsg = candidateID.toString().toBytes();



//call producer to send messages to a topic "voting" --can be in function
              checkpanic vote_producer->sendProducerRecord({
                                    topic: "voting",
                                    value: serialisedMsg });

             checkpanic vote_producer->flushRecords();
            }else{
                 io:println("vote rejected");
            }
       
        return "voted succesfully " ;
    }

// register as a voter--------------------------------------------------------
     resource function get register_vote(string name,int company_id) returns string {
            Registered_voter vote_info ={name,company_id};
            // Candidate candidate ={name,id,department};
            register_vote[company_id.toString()] = {name:name,company_id:company_id};

            byte[] serialisedMsg = vote_info.toString().toBytes();

//sending messages to Kafka for consumer get to register voters
              checkpanic vote_register_prod->sendProducerRecord({
                                    topic: "voterRegistration",
                                    value: serialisedMsg });

            checkpanic vote_register_prod->flushRecords();
            io:println(register_vote);
        return "voter registered succesfully, " + name;
    }
    //count votes 

}
//records
public type Candidate record {
    string name;
    int id;
    string department;
};

public type Vote record {
    int voterID;
    int candidateID;
    
};

public type Registered_voter record {
    string name;
    int company_id;
};
