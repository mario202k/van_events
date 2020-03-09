import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';

class HomeEvents extends StatefulWidget {
  final GlobalKey<InnerDrawerState> innerDrawerKey;

  const HomeEvents(this.innerDrawerKey);

  @override
  _HomeEventsState createState() => _HomeEventsState();
}

class _HomeEventsState extends State<HomeEvents> {
  Stream slides;
  List<Event> events = List<Event>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.secondary,
      statusBarIconBrightness: Theme.of(context).colorScheme.brightness,
      systemNavigationBarColor: Theme.of(context).colorScheme.secondary,
      systemNavigationBarIconBrightness:
          Theme.of(context).colorScheme.brightness,
    ));

    print('home_event!!!!!!!!');

    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);

//    _queryDb(false, auth);
//      SystemChrome.setPreferredOrientations([
//        DeviceOrientation.portraitUp,
//        DeviceOrientation.portraitDown,
//      ]);

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight),
              child: Column(
                children: <Widget>[
                  TopAppBar(
                      'Events',
                      true,
                      () => widget.innerDrawerKey.currentState.toggle(),
                      constraints.maxWidth),
                  IntrinsicHeight(
                    child: StreamBuilder<List<Event>>(
                        stream: db.eventsStream(),
                        initialData: List<Event>(),
                        builder: (context, AsyncSnapshot snap) {
                          List<Event> eventsList = snap.data;
                          double width = constraints.maxWidth * 0.9;

                          return Hero(
                            tag: '123',
                            child: snap.data.isNotEmpty
                                ? Swiper(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Image.network(
                                        eventsList[index].imageUrl,
                                        fit: BoxFit.fill,
                                        height: 700,
                                      );
                                    },
                                    itemCount: eventsList.length,
                                    pagination: SwiperPagination(),
                                    control: SwiperControl(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    onTap: (index) {
//                                      Navigator.pushNamed(context, '/details',
//                                          arguments: events[index]);
                                    },
                                    itemWidth: width,
                                    itemHeight: (width * 6) / 4.25,
                                    layout: SwiperLayout.TINDER,
                                    loop: true,
                                    outer: true,
                                    autoplay: true,
                                    autoplayDisableOnInteraction: false,
                                  )
                                : Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

//  Stream _queryDb(bool upcoming, FirestoreDatabase db) {
//    if (upcoming) {
//      //Make a query
//      Query query = db.db.collection('events');
////          .where('dateDebut', isGreaterThanOrEqualTo: DateTime.now());
//
//      slides = query
//          .snapshots()
//          .map((list) => list.documents.map((doc) => doc.data));
//    } else {
//      //Make a query
//      Query query = db.db.collection('events');
////          .where('dateDebut', isLessThan: DateTime.now());
//
//      slides = query
//          .snapshots()
//          .map((list) => list.documents.map((doc) => doc.data));
//    }
//
//    return slides;
//  }
}
