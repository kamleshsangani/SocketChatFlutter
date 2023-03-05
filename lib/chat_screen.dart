import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import 'message_data.dart';

class ChatPage extends StatefulWidget{
  const ChatPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }
}

class ChatPageState extends State<ChatPage>{

  IOWebSocketChannel? channel; //channel varaible for websocket
  bool? connected;

  String myId = "222"; //my id
  String receiverId = "111"; //reciever id
  String auth = "chatapphdfgjd34534hjdfk";

  List<MessageData> messageList = [];
  TextEditingController textFieldController = TextEditingController();

  @override
  void initState() {
    connected = false;
    textFieldController.text = "";
    channelConnect();
    super.initState();
  }

  void channelConnect(){ //function to connect
    try{
      channel = IOWebSocketChannel.connect("wss://demo.piesocket.com/v3/channel_123?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self"); //channel IP : Port
      channel!.stream.listen((message) {
        log("$connected");
        setState(() {
        /*  if(message == "connected"){
            connected = true;
            setState(() { });
            log("Connection established.");
          }else if(message == "send:success"){
            log("Message send success");
            setState(() {
              textFieldController.text = "";
            });
          }else if(message == "send:error"){
            log("Message send error");
          }else */
          if (message.substring(0, 6) == "{'cmd'") {
            message = message.replaceAll(RegExp("'"), '"');
            var jsonData = json.decode(message);
            if (jsonData["cmd"] == "receive") {
              log("Message data");
              connected = true;
              messageList.add(MessageData(
                messageText: jsonData["messageText"],
                userId: jsonData["userId"],
                isMe: false,));
              setState(() {});
            }
          }
        });
      },
        onDone: () {
          //if WebSocket is disconnected
          log("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          log(error.toString());
        },);
    }catch (_){
      log("error on connecting to websocket.");
    }
  }

  Future<void> sendMessage(String sendingMessage, String id) async {
      String msg = "{'auth':'$auth','cmd':'send','userId':'$id', 'messageText':'$sendingMessage'}";
      FocusScope.of(context).unfocus();
      setState(() {
        textFieldController.text = "";
        messageList.add(MessageData(
          messageText: sendingMessage, userId: myId, isMe: true,));
      });
      channel!.sink.add(msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My ID: $myId - Chat App"),
          leading: Icon(Icons.circle, color: connected! ?Colors.greenAccent:Colors.redAccent),
          //if app is connected to node.js then it will be gree, else red.
          titleSpacing: 0,
        ),
        body: SizedBox(
            child: Stack(children: [
              Positioned(
                  top:0,bottom:70,left:0, right:0,
                  child:Container(
                      padding:const EdgeInsets.all(15),
                      child: SingleChildScrollView(
                          child:Column(children: [
                            const SizedBox(
                              child:Text("Start Conversation", style: TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                                child: Column(
                                  children: messageList.map((oneMessage){
                                    return Container(
                                        margin: EdgeInsets.only( //if is my message, then it has margin 40 at left
                                          left: oneMessage.isMe ?40:0,
                                          right: oneMessage.isMe?0:40, //else margin at right
                                        ),
                                        child: Card(
                                            color: oneMessage.isMe?Colors.blue[100]:Colors.red[100],
                                            //if its my message then, blue background else red background
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(15),

                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                      child:Text(oneMessage.isMe?"ID: ME":"ID:  + ${oneMessage.userId}")
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(top:10,bottom:10),
                                                    child: Text("Message: + ${oneMessage.messageText}", style: const TextStyle(fontSize: 17)),
                                                  ),
                                                ],),
                                            )
                                        )
                                    );
                                  }).toList(),
                                )
                            )
                          ],)
                      )
                  )
              ),

              Positioned(  //position text field at bottom of screen
                bottom: 0, left:0, right:0,
                child: Container(
                    color: Colors.black12,
                    height: 70,
                    child: Row(children: [

                      Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: TextField(
                              controller: textFieldController,
                              decoration: const InputDecoration(
                                  hintText: "Enter your Message"
                              ),
                            ),
                          )
                      ),

                      Container(
                          margin: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            child: const Icon(Icons.send),
                            onPressed: (){
                              if(textFieldController.text != ""){
                                sendMessage(textFieldController.text, receiverId); //send message with webspcket
                              }else{
                                log("Enter message");
                              }
                            },
                          )
                      )
                    ],)
                ),
              )
            ],)
        )
    );
  }
}