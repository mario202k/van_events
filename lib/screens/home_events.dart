import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';

class HomeEvents extends StatefulWidget {
  final GlobalKey<InnerDrawerState> innerDrawerKey;

  const HomeEvents(this.innerDrawerKey);

  @override
  _HomeEventsState createState() => _HomeEventsState();
}

class _HomeEventsState extends State<HomeEvents> {
  Stream<List<Event>> slides;
  List<Event> events = List<Event>();

  @override
  Widget build(BuildContext context) {
    final FirestoreDatabase db =
        Provider.of<FirestoreDatabase>(context, listen: false);

    slides = db.eventsStream();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Theme.of(context).colorScheme.secondary,
      statusBarIconBrightness: Theme.of(context).colorScheme.brightness,
      systemNavigationBarColor: Theme.of(context).colorScheme.secondary,
      systemNavigationBarIconBrightness:
          Theme.of(context).colorScheme.brightness,
    ));

    print('home_event!!!!!!!!');

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
                        stream: slides,
                        initialData: List<Event>(),
                        builder: (context, AsyncSnapshot snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.secondary)),
                            );
                          } else if (snap.hasError) {
                            print(
                                'Erreur de connection${snap.error.toString()}');
                            db.showSnackBar(
                                'Erreur de connection${snap.error.toString()}',
                                context);
                            print(
                                'Erreur de connection${snap.error.toString()}');
                            return Center(
                              child: Text(
                                'Erreur de connection',
                                style: Theme.of(context).textTheme.display1,
                              ),
                            );
                          } else if (!snap.hasData) {
                            print("pas data");
                            return Center(
                              child: Text('Pas d\'evenements'),
                            );
                          }

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
                                      Navigator.of(context).pushNamed(
                                          Router.details,
                                          arguments:
                                              eventsList.elementAt(index));
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
                                    child: Text(
                                      'Pas D\'Evenements',
                                      style: Theme.of(context).textTheme.button,
                                    ),
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
