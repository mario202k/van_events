import 'dart:async';
import 'dart:io';
import 'package:bubbled_navigation_bar/bubbled_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/main.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/screens/home_events.dart';
import 'package:vanevents/screens/profile.dart';
import 'package:vanevents/screens/tickets.dart';
import 'package:vanevents/services/firebase_auth_service.dart';
import 'chat.dart';



class BaseScreens extends StatefulWidget {
  final String uid;
  final titles = ['Home', 'Chat', 'Billets', 'Profile'];
  final innerDrawer = [
    'Chat',
    'Mes billets',
    'Inviter un ami',
    'Paramètres',
    'Upload Event',
  ];

  final iconsInnerDrawer = [
    Icon(
      FontAwesomeIcons.ticketAlt,
      color: Colors.white,
      size: 22,
    ),
    Icon(
      FontAwesomeIcons.comments,
      color: Colors.white,
      size: 22,
    ),
    Icon(
      FontAwesomeIcons.shareAlt,
      color: Colors.white,
      size: 22,
    ),
    Icon(
      FontAwesomeIcons.cogs,
      color: Colors.white,
      size: 22,
    ),
    Icon(
      FontAwesomeIcons.upload,
      color: Colors.white,
      size: 22,
    ),
  ];
  final colors = [
    const Color(0xFF5D1049),
    const Color(0xFF5D1049),
    const Color(0xFF5D1049),
    const Color(0xFF5D1049)
  ];
  final icons = [
    FontAwesomeIcons.home,
    FontAwesomeIcons.comments,
    FontAwesomeIcons.ticketAlt,
    FontAwesomeIcons.user
  ];

  BaseScreens(this.uid);

  @override
  _BaseScreensState createState() => _BaseScreensState();
}

class _BaseScreensState extends State<BaseScreens> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  //inner Drawer
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();
  double _offset = 0.4;
  double _scale = 0.9;
  double _borderRadius = 50;
  bool _swipe = true;
  Color currentColor = Colors.black54;
  double _dragUpdate = 0;
  InnerDrawerAnimation _animationType = InnerDrawerAnimation.static;

  //NavigationBar
  PageController _pageController;
  bool userPageDragging = false;
  MenuPositionController _menuPositionController;

  Stream msgNonLu;

  @override
  void initState() {
    registerNotification(widget.uid);
    configLocalNotification();

    _menuPositionController = MenuPositionController(initPosition: 0);
    _pageController =
        PageController(initialPage: 0, keepPage: false, viewportFraction: 1.0);
    _pageController.addListener(handlePageChange);
    super.initState();
  }

  void registerNotification(String uid) {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
        _saveDeviceToken(uid);
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken(uid);
    }
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        showNotification(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch');
        //showNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume');

        //showNotification(message);
      },
    );

  }



  void configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  void showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'com.vaninamario.crossroads_events',
        'Crossroads Events',
        'your channel description',
        playSound: true,
        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'],
        message['data']['type']=='0'?
        message['notification']['body']:'image',
        platformChannelSpecifics,
        payload: '');
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {}

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.of(context).pushNamed(Router.baseScreens);
  }

  _saveDeviceToken(String uid) async {
    _fcm.getToken().then((fcmToken) async {
      Firestore.instance
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken)
          .setData({
        'token': fcmToken,
        'createAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }).catchError((err) {
      Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: Duration(seconds: 3),
          content: Text(
            err.message.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onError, fontSize: 16.0),
          )));
    });
  }

  void handlePageChange() {
    _menuPositionController.absolutePosition = _pageController.page;
  }

  bool checkUserDragging(ScrollNotification scrollNotification) {
    if (scrollNotification is UserScrollNotification &&
        scrollNotification.direction != ScrollDirection.idle) {
      userPageDragging = true;
    } else if (scrollNotification is ScrollEndNotification) {
      userPageDragging = false;
    }
    if (userPageDragging) {
      _menuPositionController.findNearestTarget(_pageController.page);
    }

    return userPageDragging;
  }

  Padding getIcon(int index, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Stack(
        children: <Widget>[
          Icon(widget.icons[index], size: 30, color: color),
//          index == 1
//              ? FractionalTranslation(
//            translation: Offset(0.9, -0.5),
//            child: StreamBuilder(
//                stream: msgNonLu,
//                builder: (context, snapshot) {
//                  if (!snapshot.hasData) {
//                    return SizedBox();
//                  }
//
//                  int i = 0;
//
//                  snapshot.data.forEach((queries) {
//                    queries.documents.forEach((doc) {
//                      i++;
//                    });
//                  });
//
//
//
//                  if(i>0){
//                    player.play("audio/you-have-new-message.mp3");
//                  }
//
//                  return i != 0
//                      ? Badge(
//                    badgeContent: Text('$i'),
//                  )
//                      : SizedBox();
//                }),
//          )
//              :
          SizedBox(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuthService auth =
        Provider.of<FirebaseAuthService>(context, listen: false);

    final User user = Provider.of<User>(context, listen: true);

    final toggle = Provider.of<ValueNotifier<bool>>(context, listen: false);
    return Scaffold(
      body: InnerDrawer(
          key: _innerDrawerKey,
          onTapClose: true,
          leftOffset: _offset,
          rightOffset: _offset,
          leftScale: _scale,
          rightScale: _scale,
          borderRadius: _borderRadius,
          swipe: _swipe,
          colorTransition: currentColor,
          leftAnimationType: _animationType,
          rightAnimationType: _animationType,
          innerDrawerCallback: (b) {
            toggle.value = b;
          },
          leftChild: Material(
              child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    // Add one stop for each color. Stops should increase from 0 to 1
                    //stops: [0.1, 0.5,0.5, 0.7, 0.9],
                    colors: [
                      ColorTween(
                        begin: Theme.of(context).colorScheme.secondary,
                        end: Theme.of(context).colorScheme.secondary,
                      ).lerp(_dragUpdate),
                      ColorTween(
                        begin: Theme.of(context).colorScheme.secondary,
                        end: Theme.of(context).colorScheme.secondary,
                      ).lerp(_dragUpdate),
                    ],
                  ),
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          minHeight: constraints.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(
                                top: 30, left: 15, right: 15, bottom: 80),
                            child: Stack(
                              children: <Widget>[
                                FractionalTranslation(
                                  translation: Offset(0.0, 2.1),
                                  child: RawMaterialButton(
                                    onPressed: () {},
                                    elevation: 10,
                                    shape: StadiumBorder(),
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 20.0, right: 20.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        height: 50,
                                        child: Center(
                                          child: Consumer<User>(
                                            builder: (context, user, child) {
                                              return Text(
                                                user.nom ?? '',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Align(
                                    alignment: FractionalOffset(0.5, 0.0),
                                    child: CircleAvatar(
                                      radius: 59,
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      child: Consumer<User>(
                                        builder: (context, user, child) {
                                          return user.imageUrl != null
                                              ? CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      user.imageUrl),
                                                  radius: 57,
                                                  child: RawMaterialButton(
                                                    shape: const CircleBorder(),
                                                    splashColor: Colors.grey
                                                        .withOpacity(0.4),
                                                    onPressed: () => moveTo(3),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            57.0),
                                                  ),
//                                          backgroundImage: NetworkImage(
//                                            user != null
//                                                ? user.photoUrl ??
//                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75"
//                                                : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
//                                          ),
                                                )
                                              : SizedBox();
                                        },
                                      ),
                                    )),
//                              Align(
//                                  alignment: FractionalOffset(0.5, 0.0),
//                                  child: CircularProfileAvatar(
//                                    user != null
//                                        ? user.photoUrl
//                                        : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrWfWLnxIT5TnuE-JViLzLuro9IID2d7QEc2sRPTRoGWpgJV75",
//                                    //sets image path, it should be a URL string. default value is empty string, if path is empty it will display only initials
//                                    radius: 57,
//                                    // sets radius, default 50.0
//                                    backgroundColor: Colors.transparent,
//                                    // sets background color, default Colors.white
//                                    borderWidth: 2,
//                                    // sets border, default 0.0
//
//                                    borderColor: Colors.white,
//                                    // sets border color, default Colors.white
//                                    elevation: 0.0,
//                                    // sets elevation (shadow of the profile picture), default value is 0.0
//                                    foregroundColor: Colors.transparent,
//                                    //sets foreground colour, it works if showInitialTextAbovePicture = true , default Colors.transparent
//                                    cacheImage: true,
//                                    // allow widget to cache image against provided url
//                                    onTap: () {
//                                      Navigator.of(context).pushNamed('/profile');
//                                    },
//                                    // sets on tap
//                                    showInitialTextAbovePicture:
//                                        true, // setting it true will show initials text above profile picture, default false
//                                  )),
                              ],
                              //mainAxisAlignment: MainAxisAlignment.center,
                            ),
                          ),
//                            ListView.builder(
//                              itemCount: widget.innerDrawer.length,
//                              itemBuilder: (_, i) {
//                                return Ink(
//                                  color: Theme.of(context).colorScheme.primary, // if current item is selected show blue color
//                                  child: ListTile(
//                                    title: Text(widget.innerDrawer[i]),
//                                    onTap: () {}, // reverse bool value
//                                  ),
//                                );
//                              },
//                            ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Column(
                              children: List.generate(
                                  user.email == 'mario202k@hotmail.fr'
                                      ? widget.innerDrawer.length
                                      : widget.innerDrawer.length - 1,
                                  (i) => Column(
                                        children: <Widget>[
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            // if current item is selected show blue color
                                            child: ListTile(
                                              title:
                                                  Text(widget.innerDrawer[i]),
                                              leading:
                                                  widget.iconsInnerDrawer[i],
                                              onTap: () {
                                                switch (i) {
                                                  case 0:
                                                    moveTo(1);
                                                    break;
                                                  case 1:
                                                    moveTo(2);
                                                    break;
                                                  case 4:
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            Router.uploadEvent);
                                                    break;
                                                }
                                              }, // reverse bool value
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: ListTile(
                              title: Text(
                                "Se déconnecter",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                              leading: Icon(
                                FontAwesomeIcons.signOutAlt,
                                size: 18,
                                color: Colors.white,
                              ),
                              onTap: () async {
                                await auth.signOut();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
//                _dragUpdate < 1
//                    ? BackdropFilter(
//                  filter: ImageFilter.blur(
//                      sigmaX: (10 - _dragUpdate * 10),
//                      sigmaY: (10 - _dragUpdate * 10)),
//                  child: Container(
//                    decoration: BoxDecoration(
//                      color: Colors.black.withOpacity(0),
//                    ),
//                  ),
//                )
//                    :
              null,
            ].where((a) => a != null).toList(),
          )),
          scaffold: Scaffold(
            body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                return checkUserDragging(scrollNotification);
              },
              child: PageView(
                controller: _pageController,
                children: <Widget>[
                  HomeEvents(_innerDrawerKey),
                  Chat(_innerDrawerKey),
                  Tickets(),
                  Profile()
                ],
                onPageChanged: (page) {
//                  final CurvedNavigationBarState navBarState =
//                      _bottomNavigationKey.currentState;
//                  navBarState.setPage(page);
                },
              ),
            ),
            bottomNavigationBar: BubbledNavigationBar(
              controller: _menuPositionController,
              initialIndex: 0,
              itemMargin: EdgeInsets.symmetric(horizontal: 8),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              defaultBubbleColor: Colors.blue,
              onTap: (index) {
                _pageController.animateToPage(index,
                    curve: Curves.easeInOutQuad,
                    duration: Duration(milliseconds: 500));
              },
              items: widget.titles.map((title) {
                var index = widget.titles.indexOf(title);
                var color = widget.colors[index];
                return BubbledNavigationBarItem(
                  icon: getIcon(index, color),
                  activeIcon: getIcon(index, Colors.white),
                  bubbleColor: color,
                  title: Text(
                    title,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          )),
    );
  }

  void moveTo(int i) {
    _innerDrawerKey.currentState.close();
    _pageController.animateToPage(i,
        curve: Curves.easeInOutQuad, duration: Duration(milliseconds: 500));
    _menuPositionController.animateToPosition(i);
  }
}
