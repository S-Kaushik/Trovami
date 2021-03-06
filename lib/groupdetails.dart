import 'main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'InputTextField.dart';
import 'signinpage.dart';
var httpClient = createHttpClient();

String _selectedChoice="";
var Json = const JsonCodec();
var groupname="";


TextStyle textStyle = new TextStyle(
    color:new Color.fromRGBO(0, 0, 0, 0.9),
    fontSize: 16.0,
    fontWeight: FontWeight.normal);

ThemeData appTheme = new ThemeData(
  hintColor: Colors.white,
);

Color textFieldColor = const Color.fromRGBO(0, 0, 0, 0.2);

_reviver(key,value) {

  if(key!=null&& value is Map && key.contains("-")){
    return new UserData.fromJson(value);
  }
  return value;
}

_reviver1(key,value) {

  if(key!=null&& value is Map && key.contains("-")){
    return new groupDetails.fromJson(value);
  }
  return value;
}
const jsonCodec=const JsonCodec(reviver: _reviver);

const jsonCodec1=const JsonCodec(reviver: _reviver1);

class addGroup extends StatefulWidget {
  @override
  addGroupstate createState() => new addGroupstate();
}




class addGroupstate extends State<addGroup>{
  List<UserData> userstoshowgrpdetailspage=new List<UserData>();
  final GlobalKey<ScaffoldState> _scaffoldKeySecondary1 = new GlobalKey<ScaffoldState>();
  bool _autovalidate1 = false;

  void showInSnackBar(String value) {
    _scaffoldKeySecondary1.currentState.showSnackBar(
        new SnackBar(
            content: new Text(value)
        )
    );
  }
  List<Widget> children1=new List<Widget>();
  final GlobalKey<FormState> _groupformKey = new GlobalKey<FormState>();
  List<UserData> members=[];
  int count=0;
   String checkifnotnull(String value){
     print("value:${value}");
    if(value.isEmpty) {
      return "Groupname must not be empty";
    }
    return null;
  }

   _handleSubmitted() async {

    final FormState form = _groupformKey.currentState;

      form.save();
      UserData loggedinmember = new UserData();
      loggedinmember.EmailId = loggedinuser;
      loggedinmember.locationShare = false;
      for (var i = 0; i < members.length; i++) {
        grpd.groupmembers.add(members[i]);
      }
    loggedinmember.name=loggedinusername;

    grpd.groupmembers.add(loggedinmember);


      for (var i = 0; i < grpd.groupmembers.length; i++) {
        var groupsiaminurl = 'https://fir-trovami.firebaseio.com/users.json?orderBy="\$key"';
        var response = await httpClient.get(groupsiaminurl);
        Map resstring = jsonCodec.decode(response.body);
        resstring.forEach((k, v) async {

          if (v.EmailId == grpd.groupmembers[i].EmailId) {
            if (v.groupsIamin == null) {
              List<String> groupsIamin = [];
              groupsIamin.add(grpd.groupname);
              var groupsIaminjson = jsonCodec.encode(groupsIamin);
              var response1 = await httpClient.put(
                  'https://fir-trovami.firebaseio.com/users/${k}/groupsIamin.json?',
                  body: groupsIaminjson);
            }
            else {
              var response2 = await httpClient.get(
                  'https://fir-trovami.firebaseio.com/users/${k}/groupsIamin.json?');
              List<String> resmap = jsonCodec.decode(response2.body);
              resmap.add(grpd.groupname);
              var groupsIaminjson = jsonCodec.encode(resmap);
              var response1 = await httpClient.put(
                  'https://fir-trovami.firebaseio.com/users/${k}/groupsIamin.json?',
                  body: groupsIaminjson);
            }
          }
        });
      }

    var groupjson = jsonCodec1.encode(grpd);
    var url = "https://fir-trovami.firebaseio.com/groups.json";
    await httpClient.post(url, body: groupjson);

    Navigator.of(context).pushReplacementNamed('/b');

  }
  void _select(UserData user) {
    members.add(user);
    for(var i=0;i<userstoshowgrpdetailspage.length;i++){
      if(userstoshowgrpdetailspage[i].EmailId==user.EmailId){
        userstoshowgrpdetailspage.removeAt(i);
      }
    }
    setState(() {
      popflag=1;
      userstoshowgrpdetailspage=userstoshowgrpdetailspage;
      count = count + 1;
    });
  }

  getusers()async{
    var url="https://fir-trovami.firebaseio.com/users.json";
    var response=await httpClient.get(url);
    Map resstring=jsonCodec.decode(response.body);
    resstring.forEach((k,v){
      UserData usertoshow=new UserData();
      usertoshow.name=v.name;
      usertoshow.EmailId = v.EmailId;
      usertoshow.locationShare=false;
      if(usertoshow.EmailId==loggedinuser){

      }else {
        userstoshowgrpdetailspage.add(usertoshow);
      }
    });
  }

  @override
  void initState() {
    getusers();
  }

  @override
  Widget build(BuildContext context) {





if(members.length!=0) {
  children1 =
  new List.generate(count, (int i) => new memberlist(members[i].name));
}

    return new Scaffold(
      key: _scaffoldKeySecondary1,
      body: new Form(
        autovalidate: true,

        key: _groupformKey,
        child: new ListView(
          padding: new EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[

            new Container(
              child: new Container(
                child: new Text("Group Details",
                  style: new TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                padding: new EdgeInsets.only(bottom:20.0),
              ),
              padding: new EdgeInsets.only(top:50.0),
              decoration: new BoxDecoration(
                border: new Border(
                  bottom: new BorderSide(width: 0.0, color: Colors.brown[200]),
                ),
              ),
            ),
            new Container(
                child: new Container(
                  child: new InputField(
                      hintText: "Groupname",
                      obscureText: false,
                      textInputType: TextInputType.text,
                      textStyle: textStyle,
                      textFieldColor: textFieldColor,
                      icon: Icons.group,
                      validateFunction: checkifnotnull,
                      iconColor: Colors.grey,
                      bottomMargin: 20.0,
                      onSaved: (String value) {
                        grpd.groupname=value;
                        grpd.groupmembers=new List<UserData>();
                      }
                  ),
                  padding: new EdgeInsets.only( bottom:15.0, top:0.0,right: 20.0),
                ),
                padding: new EdgeInsets.only( top:30.0)
            ),
            new Row(children: <Widget>[
              new Container(child:
              new Text("Add a member:",style: new TextStyle(fontSize: 16.0,
                  fontWeight: FontWeight.bold),),
                  padding: new EdgeInsets.only( left:13.0)

              ),
              new Container(child:
                new CircleAvatar(child:
                  new PopupMenuButton<UserData>(
                    icon: new Icon(Icons.add),
                    onSelected: _select,
                    itemBuilder: (BuildContext context) {
                      return userstoshowgrpdetailspage.map((UserData usertoshow) {
                        return new PopupMenuItem<UserData>(
                          value: usertoshow,
                          child: new Text(usertoshow.name),
                        );
                      }).toList();
                    },
                  ),
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.2),
                ),
                  padding: new EdgeInsets.only( left:50.0)
              ),
            ],
            ),
            new Column(
              children:children1,
            ),
            new Row(children: <Widget>[

    new Container(
              alignment: Alignment.bottomCenter,
              child: new FloatingActionButton(
                onPressed: _handleSubmitted,
                child: new Icon(Icons.check),
              ),
              padding: new EdgeInsets.only( top:50.0,left: 100.0) ,
            ),
    new Container(
      child:new FloatingActionButton(
        onPressed:    Navigator.of(context).pop,
        child: new Icon(Icons.clear),
        heroTag: null,
      ),
      padding: new EdgeInsets.only( top:50.0,left: 50.0) ,
    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class memberlist extends StatelessWidget {
  final String mem;
  memberlist(this.mem);

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new CircleAvatar(
                  child:new Icon(Icons.person),
                  backgroundColor: const Color.fromRGBO(0, 0, 0, 0.2),
                ),
                new Container(child:
                new Text(
                    "${mem}",
                    style: new TextStyle(fontSize: 20.0),
                ),
                    padding: new EdgeInsets.only( left:20.0)

                ),
              ],
            ),
          ],
        ),
        padding: new EdgeInsets.only( left:10.0,top: 5.0,bottom: 5.0),
        decoration: new BoxDecoration(
          border: new Border(
            bottom: new BorderSide(width: 0.0, color: const Color.fromRGBO(0, 0, 0, 0.2),),
          ),
        ),
    );
  }
}
