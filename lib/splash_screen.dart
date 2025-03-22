
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/data_response.dart';
import 'features/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  var dataSet;
  String urlPolicy = "";
  bool isShowIDFA = false;
  late MethodChannel platform;
  late String methodChannelName; // No longer final, initialized in initState
  late String apiUrl; // No longer final, initialized in initState
  late Map<String, dynamic> requestBody; // No longer final, initialized in initState

  @override
  void initState() {
    super.initState();

    methodChannelName = 'com.sport1/channel';
    apiUrl = 'https://api-chlay-all.onrender.com/api/dataapp';
    requestBody = {'app': 'ios8-rm'};

    platform = MethodChannel(methodChannelName);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    WidgetsBinding.instance.addObserver(this);
    requestIDFA();
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _showNoInternetDialog() async {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog
                await _loadData(); // Retry fetching data
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  Future<String> getTimeZoneName()  async {
      try {
        final String? timeZone = await platform.invokeMethod('getTimeZone');
        return timeZone??"";
      } on PlatformException catch (e) {
        print("Failed to get timezone: '${e.message}'.");
        return "";
      }
  }
  Future<void> _loadData() async {
    final startTime = DateTime.now();

    DataResponse? data = await fetchData();

    final elapsedTime = DateTime.now().difference(startTime).inMilliseconds;
    const minSplashTime = 2000;

    if (elapsedTime < minSplashTime) {
      await Future.delayed(Duration(milliseconds: minSplashTime - elapsedTime));
    }

    if (data != null) {
      if (mounted) {
        if (data.isSuccess == '1' && data.data.isNotEmpty) {
          dataSet = data;
          sentDataToMethodChannel(dataSet);
        } else {
          if (isShowIDFA) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => const HomeScreen()), (Route<dynamic> route) => false,);
          }
        }
      }
    }
  }

  Future<void> sentDataToMethodChannel(DataResponse data) async {
    try {
      await platform.invokeMethod('sendData', {'data': data.toJson()});
      print('Data sent successfully');
    } on PlatformException catch (e) {
      print('Failed to send data: ${e.message}');
    }
  }

  Future<void> requestIDFA() async {
    try {
      final bool result = await platform.invokeMethod('requestIDFA');
      isShowIDFA = true;
      print("requestIDFA $result");
    } on Exception catch (e) {
      isShowIDFA = true;
      print("Failed to get IDFA: '${e}'.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (dataSet != null) {
        sentDataToMethodChannel(dataSet);
      }
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<DataResponse?> fetchData() async {
    String time = await getTimeZoneName();
    try {
      final response = await Dio().post(
        apiUrl,
        data: {
          ...requestBody,
          'time':time.toLowerCase(),
          'country': WidgetsBinding.instance.platformDispatcher.locale.countryCode?.toLowerCase(),
        },
      );
      if (response.statusCode == 200) {
        return DataResponse.fromJson(response.data);
      } else {
        print('Failed to load data: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        _showNoInternetDialog();
      }
      print('Error fetching data: $e');
      return null;
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text("Math Fun",style: TextStyle(color: Color(0xFF303F9F),fontSize: 26,fontWeight: FontWeight.w900),),
        ),
        decoration: const BoxDecoration(
         color:  Colors.white,
        ),
      ),
    );
  }
}
