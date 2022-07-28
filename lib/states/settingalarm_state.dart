import 'package:flutter/material.dart';
import 'package:teragate_test/models/storage_model.dart';



class SettingAlarm extends StatefulWidget {
  
  const SettingAlarm( Key? key) : super(key: key);

  @override
  SettingAlarmState createState() => SettingAlarmState();
}

class SettingAlarmState extends State<SettingAlarm> {

  late SecureStorage strage;
  bool switchval = true;
  bool switchval2 = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  get children => null;

  @override
  void initState() {
    super.initState();
    
    strage = SecureStorage();
  }
  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
          leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.of(context).pop(),
  ), 
        backgroundColor: const Color(0x0fff5f5f),
        automaticallyImplyLeading: true,
        title: const Text(
          '알람 설정',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400)
        ),
        actions: const [],
        centerTitle: true,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: 
      FutureBuilder(
        future: setuuid(),
        builder: (context, snapshot) {
        if (snapshot.hasData == false) {
          return const CircularProgressIndicator(); 
        }
        else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); 
        }
        else { 
        return 
        SafeArea(
        child: Column( children: <Widget>[
          GestureDetector(          
                onTap: () { 
                  Switch(
                    value: switchval2 ,
                    onChanged: (newValue){
                    setState(() => switchval2 = newValue);
                    strage.write("Alarm", switchval2.toString());
                    },
                  );

    },
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
              ),
            child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText( 
                text: const TextSpan(children: [
                  TextSpan(
                    text: '진 동',
                    style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400)),
                    ]),
                    ),
                    Align(                                          
                    child: Switch(
                      value: switchval ,
                      onChanged: (newValue){
                      setState(() => switchval = newValue);
                      strage.write("VIBRATE", switchval.toString());
                      },
                      ),
                      ),
                      ],
                      ),
                      ),
        ),
          GestureDetector(          
              onTap: () { 
              },
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText( 
                    text: const TextSpan(children: [
                        TextSpan(
                            text: '알람음' ,
                            style: TextStyle(color: Colors.red,fontSize: 20, fontWeight: FontWeight.w400), ),
                      ]),
                  ),
                  Switch(
                    value: switchval2 ,
                    onChanged: (newValue){
                    setState(() => switchval2 = newValue);

                    strage.write("Alarm", switchval2.toString());
                    },
                  ),  
                ],
              ),
          ),
          )
        ],
      ),
      );
      }})
    );
  }
  
  Future<String> setuuid() async{
     String? vibrate = await strage.read("VIBRATE");
     String? alarm = await strage.read("Alarm");
     
     if(vibrate==null){
      setState(() {
        switchval = false; 
      });
     }
     if(alarm== null){
      setState(() {
       switchval2 = false; 
      });
     }
     if(vibrate=="true")switchval= true;
     if(vibrate=="false")switchval= false;
     if(alarm=="true")switchval2= true;
     if(alarm=="false")switchval2= false; 
     
     // 리턴 값이 있어야 감지가 됩니다!
     return "re";
  }
}
