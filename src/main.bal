import ballerina/io;
import ballerina/http;


//interface that we interact with when we first start the project
http:Client clientEndpoint = check new ("http://localhost:9090");
public function main () {

        io:println("WELCOME TO VoTo");
        io:println("------------------------");
        io:println("Have you registered to vote ");
        io:println("press 1 for yes  ");// vote
        io:println("press 2 for no  "); // register to vote
        io:println("press 3 for candidate register  ");

        
       string choice = io:readln("Enter choice :");

       if (choice === "1"){
          string vID = io:readln("Enter voter ID :");
          string cID  = io:readln("Enter  candidate id  :");

             //accessing the graphql service vID 
             var  response = clientEndpoint->post("/graphql",{ query: " { vote(voterID:"+vID+",candidateID:"+cID+") }" });
        
            if (response is  http:Response) {
                var jsonResponse = response.getJsonPayload();

                if (jsonResponse is json) {
                    
                    io:println(jsonResponse);
                } else {
                    io:println("Invalid payload received:", jsonResponse.message());
                }

             }

       }else if (choice=="2"){
          //------------------------ registering voters ------------------------
           string name = io:readln("Enter Name :");
           string nam_id  = io:readln("Enter voter ID  :");
  

             var  response = clientEndpoint->post("/graphql",{ query: " { register_vote(name:\""+name+"\",namibian_id:"+nam_id+") }" });
           // io:println(response);
            if (response is  http:Response) {
                var jsonResponse = response.getJsonPayload();

                if (jsonResponse is json) {
                    
                    io:println(jsonResponse);
                } else {
                    io:println("Invalid payload received:", jsonResponse.message());
                }

             }
       }else if (choice === "3"){
           //------------------------ register candidate ------------------------
           string name = io:readln("Enter Name :");
           string nam_id  = io:readln("Enter Namibian ID  :");
           string ruling_party  = io:readln("Enter Ruling  Party  :");

           int|error id = 'int:fromString(nam_id);  
             
             var  response = clientEndpoint->post("/graphql",{ query: " { register_candidate(name:\""+name+"\",id:"+nam_id+",ruling_party:\""+ruling_party+"\") }" });
           // io:println(response);
            if (response is  http:Response) {
                var jsonResponse = response.getJsonPayload();

                if (jsonResponse is json) {
                    
                    io:println(jsonResponse);
                } else {
                    io:println("Invalid payload received:", jsonResponse.message());
                }

             }
           }

      
}
