import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'mediaPlayerViewDialogForUrls.dart';
import 'mediaPlayerViewDialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'settings.dart';
import 'package:flutter/widgets.dart';

import 'language.dart';
import 'package:http/http.dart' as http;
import 'viewText.dart';
import 'app.dart';
import 'contectUs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Language.runTranslation();
  runApp(test());
}
class test extends StatefulWidget{
  const test({Key?key}):super(key:key);
  @override
  State<test> createState()=>_test();
}
class _test extends State<test>{
  var youtube=false;
  TextEditingController URLControler=TextEditingController();
  var _=Language.translate;
  _test();
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      locale: Locale(Language.languageCode),
      title: App.name,
      themeMode: ThemeMode.system,
      home:Builder(builder:(context) 
    =>Scaffold(
      appBar:AppBar(
        title: const Text(App.name),), 
        drawer: Drawer(
          child:ListView(children: [
          DrawerHeader(child: Text(_("navigation menu"))),
          ListTile(title:Text(_("settings")) ,onTap:() async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) =>SettingsDialog(this._) ));
            setState(() {
              
            });
          } ,),
          ListTile(title: Text(_("contect us")),onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ContectUsDialog(this._)));
          },),
          ListTile(title: Text(_("donate")),onTap: (){
            launch("https://www.paypal.me/AMohammed231");
          },),
  ListTile(title: Text(_("visite project on github")),onTap: (){
    launch("https://github.com/mesteranas/"+App.appName);
  },),
  ListTile(title: Text(_("license")),onTap: ()async{
    String result;
    try{
    http.Response r=await http.get(Uri.parse("https://raw.githubusercontent.com/mesteranas/" + App.appName + "/main/LICENSE"));
    if ((r.statusCode==200)) {
      result=r.body;
    }else{
      result=_("error");
    }
    }catch(error){
      result=_("error");
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewText(_("license"), result)));
  },),
  ListTile(title: Text(_("about")),onTap: (){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(title: Text(_("about")+" "+App.name),content:Center(child:Column(children: [
        ListTile(title: Text(_("version: ") + App.version.toString())),
        ListTile(title:Text(_("developer:")+" mesteranas")),
        ListTile(title:Text(_("description:") + App.description))
      ],) ,));
    });
  },)
        ],) ,),
        body:Container(alignment: Alignment.center
        ,child: Column(children: [
          ElevatedButton(onPressed: () async{
            var result=await FilePicker.platform.pickFiles();
            if (result!=Null){
              var media=result?.files.first.path??"";
              Navigator.push(context, MaterialPageRoute(builder: (context)=>MediaPlayerViewer(FilePath: media,)));
            }

          }, child: Text(_("open local file"))),
          ElevatedButton(onPressed: (){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text(_("enter url")    ),
                content: Center(
                  child: Column(
                    children: [
                      Row(children: [
                      Checkbox(value: youtube, onChanged: (bool?value){
                        setState(() {
                          youtube=value??false;
                        });
                      },
                      ),
                      Text(_("youtube"))
                      ]),
                      TextFormField(controller: URLControler,),
                      ElevatedButton(onPressed: () async{
                        var url;
                        if (youtube){
                          var IT=YoutubeExplode();
                          var video=await IT.videos.get(URLControler.text);
                          var man=await IT.videos.streamsClient.getManifest(video.id);
                          var stream=man.streams.first;
                          url=stream.url;
                        } else{
                        url=Uri.parse(URLControler.text.replaceAll("http://", "https://"));
                        }
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>MediaPlayerURLViewer(FilePath: url.toString())));
                      }, child: Text(_("go"))),
                    ],
                  ),
                ),
              );
            });
          }, child: Text(_("open link from internet"))),
    ])),)));
  }
}
