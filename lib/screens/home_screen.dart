import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    ///Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      //app bar
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.changeThemeMode(
                  Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              Pref.isDarkMode = !Pref.isDarkMode;
              // print('\n*********************************************** mode is ${Pref.isDarkMode}');
              return;
            },
            icon: const Icon(
              Icons.brightness_medium,
              size: 26,
            )),
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Cyber',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: 'Shield',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
              padding: const EdgeInsets.only(right: 8),
              onPressed: () => Get.to(() => const NetworkTestScreen()),
              icon: const Icon(
                CupertinoIcons.info,
                size: 27,
              )),
        ],
      ),

      bottomNavigationBar: _changeLocation(context),

      //body
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        //vpn button
        Obx(() => _vpnButton()),

        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //country flag
              HomeCard(
                  title: _controller.vpn.value.countryLong.isEmpty
                      ? 'Country'
                      : _controller.vpn.value.countryLong,
                  subtitle: 'FREE',
                  icon: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue,
                    child: _controller.vpn.value.countryLong.isEmpty
                        ? const Icon(Icons.vpn_lock_rounded,
                            size: 30, color: Colors.white)
                        : null,
                    backgroundImage: _controller.vpn.value.countryLong.isEmpty
                        ? null
                        : AssetImage(
                            'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png'),
                  )),

              //ping time
              HomeCard(
                  title: _controller.vpn.value.countryLong.isEmpty
                      ? '100 ms'
                      : '${_controller.vpn.value.ping} ms',
                  subtitle: 'PING',
                  icon: const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.orange,
                    child: Icon(Icons.equalizer_rounded,
                        size: 30, color: Colors.white),
                  )),
            ],
          ),
        ),

        StreamBuilder<VpnStatus?>(
            initialData: VpnStatus(),
            stream: VpnEngine.vpnStatusSnapshot(),
            builder: (context, snapshot) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //download
                    HomeCard(
                        title: '${snapshot.data?.byteIn ?? '0 kbps'}',
                        subtitle: 'DOWNLOAD',
                        icon: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.lightGreen,
                          child: Icon(Icons.arrow_downward_rounded,
                              size: 30, color: Colors.white),
                        )),

                    //upload
                    HomeCard(
                        title: '${snapshot.data?.byteOut ?? '0 kbps'}',
                        subtitle: 'UPLOAD',
                        icon: const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.arrow_upward_rounded,
                              size: 30, color: Colors.white),
                        )),
                  ],
                ))
      ]),
    );
  }

  //vpn button
  Widget _vpnButton() => Column(
        children: [
          //button
          Semantics(
            button: true,
            child: InkWell(
              onTap: () {
                _controller.connectToVpn();
              },
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _controller.getButtonColor.withOpacity(.3)),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _controller.getButtonColor.withOpacity(.3)),
                  child: Container(
                    width: mq.height * .14,
                    height: mq.height * .14,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _controller.getButtonColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        const Icon(
                          Icons.power_settings_new,
                          size: 28,
                          color: Colors.white,
                        ),

                        const SizedBox(height: 4),

                        //text
                        Text(
                          _controller.getButtonText,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          //connection status label
          Container(
            margin:
                EdgeInsets.only(top: mq.height * .015, bottom: mq.height * .02),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
                color: _controller.getButtonColor,
                borderRadius: BorderRadius.circular(15)),
            child: Text(
              _controller.vpnState.value == VpnEngine.vpnDisconnected
                  ? 'Not Connected'
                  : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
              style: const TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),

          //count down timer
          Obx(() => CountDownTimer(
              startTimer:
                  _controller.vpnState.value == VpnEngine.vpnConnected)),
        ],
      );

  //bottom nav to change location
  Widget _changeLocation(BuildContext context) => SafeArea(
          child: Semantics(
        button: true,
        child: InkWell(
          onTap: () => Get.to(() => LocationScreen()),
          child: Container(
              color: Theme.of(context).bottomNav,
              padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
              height: 60,
              child: const Row(
                children: [
                  //icon
                  Icon(CupertinoIcons.globe, color: Colors.white, size: 28),

                  //for adding some space
                  SizedBox(width: 10),

                  //text
                  Text(
                    'Change Location',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),

                  //for covering available spacing
                  Spacer(),

                  //icon
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.keyboard_arrow_right_rounded,
                        color: Color.fromARGB(255, 11, 15, 18), size: 26),
                  )
                ],
              )),
        ),
      ));
}
