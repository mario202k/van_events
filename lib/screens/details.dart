import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/event.dart';
import 'package:vanevents/models/formule.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';

class Details extends StatefulWidget {
  final Event event;

  Details(this.event);

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  Stream<List<User>> participants;
  List<Formule> formulas;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    participants = db.participantsStream(widget.event.id);
    db.getFormulasList(widget.event.id).then((form){formulas = form;});

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
//              actions: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(right: 20),
//                  child: InkWell(
//                    onTap: () {
//                      Navigator.of(context).pushNamed('/pay');
//                    },
//                    child: Icon(
//                      FontAwesomeIcons.cartArrowDown,
//                      color: Colors.white,
//                    ),
//                  ),
//                )
//              ],
              expandedHeight: 300,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(widget.event.titre,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline),
                background: Hero(
                    tag: '123',
                    child: Image(
                      image: widget.event.imageProvider,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
          ];
        },
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "${DateFormat('dd/MM/yyyy').format(widget.event.dateDebut.toDate())} à : ${widget.event.dateDebut.toDate().hour}:${widget.event.dateDebut.toDate().minute}"),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Plannifier"),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.map,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Allons-y"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                height: 1,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle, color: Colors.black26),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                child: new Text(
                  "Description",
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                widget.event.description,
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                height: 1,
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle, color: Colors.black26),
              ),
              SizedBox(
                height: 25,
              ),
              Text(
                "Participants",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                height: 200,
                child: StreamBuilder<List<User>>(
                    stream: participants,
                    initialData: List<User>(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Erreur de connection'),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).colorScheme.secondary)),
                        );
                      }
                      List<User> participantsList = snapshot.data;
                      return participantsList.isNotEmpty
                          ? ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: participantsList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(6),
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                            participantsList[index].imageUrl),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : SizedBox();
                    }),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: RawMaterialButton(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const <Widget>[
                Icon(
                  FontAwesomeIcons.cartArrowDown,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 15,
                ),
                PulseAnimation(
                  child: Text(
                    "PARTICIPER",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          shape: StadiumBorder(),
          fillColor: Theme.of(context).colorScheme.primary,
          onPressed: () {
            Navigator.of(context).pushNamed(Router.formulaChoice,arguments: formulas);
          }),
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Widget child;

  const PulseAnimation({Key key, this.child}) : super(key: key);

  @override
  _PulseAnimationState createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween(begin: .2, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}
