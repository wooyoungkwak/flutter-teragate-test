import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';

import 'package:teragate_test/config/env.dart';
import 'package:teragate_test/models/storage_model.dart';
import 'package:teragate_test/utils/debug_util.dart';
import 'package:teragate_test/utils/time_util.dart';

import '../models/beacon_model.dart';

// 비콘 초기화
Future<void> initBeacon(Function setNotification, Function setForGetInOut, StreamController beaconStreamController, SecureStorage secureStorage) async {
  if (Platform.isAndroid) {
    await BeaconsPlugin.setDisclosureDialogMessage(title: "Need Location Permission", message: "This app collects location data to work with beacons.");

    BeaconsPlugin.channel.setMethodCallHandler((call) async {
      if (Env.isDebug) Log.debug(" ********* Call Method: ${call.method}");

      if (call.method == 'scannerReady') {
        await _setBeacon();
        await startBeacon();
      } else if (call.method == 'isPermissionDialogShown') {
        setNotification("Beacon 을 검색 할 수 없습니다. 권한을 확인 하세요.");
      }
    });

    BeaconsPlugin.listenToBeacons(beaconStreamController);
  } else if (Platform.isIOS) {
    BeaconsPlugin.setDebugLevel(2);

    BeaconsPlugin.listenToBeacons(beaconStreamController);

    Future.delayed(const Duration(milliseconds: 3000), () async {
      _setBeacon();
      await startBeacon();
    }); //Send 'true' to run in background

    Future.delayed(const Duration(milliseconds: 3000), () async {
      await BeaconsPlugin.runInBackground(true);
    }); //Send 'true' to run in background
  }

  beaconStreamController.stream.first.then((data) async {
    //리슨타면 일단 스캔멈추기.
    if (data.isNotEmpty) {
      String? uuid = await secureStorage.read(Env.KEY_UUID);
      uuid = uuid!.toUpperCase();
      
      Map<String, dynamic> userMap = jsonDecode(data);
      var iBeacon = BeaconData.fromJson(userMap);
      if (iBeacon.uuid != uuid) {
        return;
      }

      String beaconKey = iBeacon.minor; // 비콘의 key 값
      if (beaconKey != getMinorToDate()) {
        setNotification(Env.MSG_MINOR_FAIL); // 다이얼로그창
      } else {
        setForGetInOut();
      }

      BeaconsPlugin.stopMonitoring();
    } else {
      //데이터가 없지만 리슨으로 들어 온 경우...
      Log.debug("========== 일단 여기들어오면 됨. ========== ");
      BeaconsPlugin.stopMonitoring();
    }
  });

}

Future<void> _setBeacon() async {
  await BeaconsPlugin.addRegion("iBeacon", "74278bdb-b644-4520-8f0c-720eeaffffff");
  if (Platform.isAndroid) {
    BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24");
    BeaconsPlugin.addBeaconLayoutForAndroid("m:2-3=beac,i:4-19,i:20-21,i:22-23,p:24-24,d:25-25");
    BeaconsPlugin.setForegroundScanPeriodForAndroid(foregroundScanPeriod: 2200, foregroundBetweenScanPeriod: 10);
    BeaconsPlugin.setBackgroundScanPeriodForAndroid(backgroundScanPeriod: 2200, backgroundBetweenScanPeriod: 10);
  }
}

// 비콘 시작
Future<void> startBeacon() async {
  await BeaconsPlugin.startMonitoring();
}

// 비콘 멈춤
Future<void> stopBeacon() async {
  await BeaconsPlugin.stopMonitoring();
}
