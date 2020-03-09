import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/services/firestore_database.dart';

class TopAppBar extends StatefulWidget {
  final String title;
  final bool isMenu;
  final VoidCallback onPressed;
  final double widthContainer;
  final double heightContainer = 120;

  TopAppBar(this.title, this.isMenu, this.onPressed, this.widthContainer);

  @override
  _TopAppBarState createState() => _TopAppBarState();
}

class _TopAppBarState extends State<TopAppBar> with TickerProviderStateMixin {
  bool startAnimation = false;
  AnimationController animationController;
  bool disposed = false;

  _afterLayout(_) {
    setState(() {
      startAnimation = !startAnimation;
    });
  }

  @override
  void initState() {
    if (widget.isMenu) {
      animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 400));
    }
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isMenu) {
      disposed = true;
      if (animationController != null) animationController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context,listen: false);
    if (widget.isMenu) {
      final toggle = Provider.of<ValueNotifier<bool>>(context, listen: false);
      

      toggle.addListener(() {
        if (!disposed) {
          if (toggle.value) {
            animationController.forward();
          } else {
            animationController.reverse();
          }
        }
      });
    }

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20.5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: widget.isMenu
                      ? AnimatedIcon(
                    icon: AnimatedIcons.menu_arrow,
                    progress: animationController,
                    color: Theme.of(context).colorScheme.onSecondary,
                  )
                      : Icon(
                    Platform.isAndroid
                        ? Icons.arrow_back
                        : Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    widget.isMenu ? widget.onPressed() : Navigator.pop(context);
                  },
                ),
                Flexible(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.display3.copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                ),

              ],
            ),
          ),
        ),
        ClipPath(
          clipper: widget.title == 'Chat' ? ClippingChatClass() : ClippingClass(),
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            height: startAnimation ? widget.heightContainer : 0,
            width: widget.widthContainer,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary
              ]),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  icon: widget.isMenu
                      ? AnimatedIcon(
                          icon: AnimatedIcons.menu_arrow,
                          progress: animationController,
                          color: Theme.of(context).colorScheme.onSecondary,
                        )
                      : Icon(
                          Platform.isAndroid
                              ? Icons.arrow_back
                              : Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  onPressed: () {
                    widget.isMenu ? widget.onPressed() : Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.display3,
                  ),
                ),
                widget.title == 'Chat' ? PopupMenuButton<String>(color: Theme.of(context).colorScheme.primary,
                  onSelected: (String value) async {
                    switch (value) {
                      case 'Value1':
                        final User userFriend = await showSearch(
                            context: this.context,
                            delegate: UserSearch(UserBlocSearchName()));

                        if (userFriend != null) {
                          db
                              .creationChatRoom(userFriend.id)
                              .then((chatId) {
//                    Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                            builder: (context) => ChatRoom(
//                                myId,
//                                userFriend.nom,
//                                userFriend.image,
//                                chatId,
//                                userFriend.id)));
                          });
                        }

                        break;
                      case 'Value2':

//                    final User userFriend = await showSearch(
//                        context: this.context,
//                        delegate: UserSearch(UserBlocSearchEvent()));

//                    if (userFriend != null) {
//                      _auth.creationChatRoom(myId, userFriend.id).then((
//                          chatId) {
//                        Navigator.push(
//                            context,
//                            MaterialPageRoute(
//                                builder: (context) =>
//                                    ChatRoom(myId, userFriend.nom,
//                                        userFriend.image, chatId,
//                                        userFriend.id)));
//                      });
//                    }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Icon(FontAwesomeIcons.search,color: Theme.of(context).colorScheme.background,),
                  ),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'Value1',
                      child: Text('Par Nom'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'Value2',
                      child: Text('Y était aussi'),
                    ),
                  ],
                ) : SizedBox(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ClippingClassBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height * 0.7);

    //path.lineTo(0.0, size.height);

    path.lineTo(size.width, 0);

    path.lineTo(size.width, size.height);

    path.lineTo(0.0, size.height);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class ClippingClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width, size.height * 0.3);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
class ClippingChatClass extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height);

    path.lineTo(size.width*0.85, size.height*0.5);
    path.quadraticBezierTo(size.width*0.97, size.height*0.95, size.width, size.height*.6);
    path.lineTo(size.width, size.height);

    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}
class UserSearch extends SearchDelegate<User> {
  final Bloc<UserSearchEvent, UserSearchState> userBloc;

  UserSearch(this.userBloc);


  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context);
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: BackButtonIcon(),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    User user = Provider.of<User>(context);
    userBloc.add(UserSearchEvent(query, user.id));

    return BlocBuilder(
      bloc: userBloc,
      builder: (BuildContext context, UserSearchState state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Container(
            child: Text('Error'),
          );
        }

//        int j;
//
//        for (int i = 0; i < state.users.length; i++) {
//          if (state.users[i].id == user.uid) {
//            j = i;
//            break;
//          }
//        }
//
//        if (j != null) state.users.removeAt(j);

        return ListView.builder(
          itemBuilder: (context, index) {
            print(index);
            return ListTile(
              title: Text(state.users[index].nom ?? ''),
              leading: CircleAvatar(
                backgroundImage: NetworkImage(state.users[index].imageUrl),
                radius: 25,
              ),
              onTap: () {
                close(context, state.users[index]);
              },
            );
          },
          itemCount: state.users.length,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // This method is called everytime the search term changes.
    // If you want to add search suggestions as the user enters their search term, this is the place to do that.
    User user = Provider.of<User>(context);
    userBloc.add(UserSearchEvent(query, user.id));

    return BlocBuilder(
      bloc: userBloc,
      builder: (BuildContext context, UserSearchState state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.hasError) {
          return Container(
            child: Text('Error'),
          );
        }

//        int j;
//
//        for (int i = 0; i < state.users.length; i++) {
//          if (state.users[i].id == user.uid) {
//            j = i;
//            break;
//          }
//        }
//
//        if (j != null) state.users.removeAt(j);

        return Container(
          color: Theme.of(context).colorScheme.background,
          child: ListView.builder(
            itemBuilder: (context, index) {
              print(index);
              return ListTile(
                title: Text(state.users[index].nom ?? ''),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(state.users[index].imageUrl),
                  radius: 25,
                ),
                onTap: () {
                  close(context, state.users[index]);
                },
              );
            },
            itemCount: state.users.length,
          ),
        );
      },
    );
  }
}
class UserBlocSearchName extends Bloc<UserSearchEvent, UserSearchState> {
  List<User> users = List<User>();

  @override
  UserSearchState get initialState => UserSearchState.initial();

  @override
  void onTransition(Transition<UserSearchEvent, UserSearchState> transition) {
    print(transition.toString());
  }

  @override
  Stream<UserSearchState> mapEventToState(UserSearchEvent event) async* {
    yield UserSearchState.loading();

    try {
      List<User> users = await _getSearchResults(event.query,event.myId);
      yield UserSearchState.success(users);
    } catch (err) {
      yield UserSearchState.error();
    }
  }

  Future<List<User>> _getSearchResults(String query,String myId) async {
    List<User> result = List<User>();

    if (users.isEmpty) {
//      FirebaseUser me = await _auth.auth.currentUser();
//
//      User mee = await _auth.getUserFirestore(me.uid);
//      users = await _auth.db.collection('users').getDocuments().then(
//          (docs) =>
//              docs.documents.map((doc) => User.fromMap(doc.data)).toList());

      print("$myId!!!!!!!!!!!!");
      List<User> user1 = await Firestore.instance
          .collection('users')
          .where('id', isGreaterThan: myId)
          .getDocuments()
          .then((docs) =>
          docs.documents.map((doc) => User.fromMap(doc.data,doc.documentID)).toList());
      List<User> user2 = await Firestore.instance
          .collection('users')
          .where('id', isLessThan: myId)
          .getDocuments()
          .then((docs) =>
          docs.documents.map((doc) => User.fromMap(doc.data,doc.documentID)).toList());

      users = List.from(user1)..addAll(user2); //Tout le monde sauf moi



      result = List.from(users);

    } else {
      users.forEach((user) {
        if (user.nom.contains(query)) {
          result.add(user);
        }
      });
    }

    return result;
  }
}
class UserSearchEvent {
  final String query;
  final String myId;

  const UserSearchEvent(this.query,this.myId);

  @override
  String toString() => 'UserSearchEvent { query: $query }';
}

class UserSearchState {
  final bool isLoading;
  final List<User> users;
  final bool hasError;

  const UserSearchState({this.isLoading, this.users, this.hasError});

  factory UserSearchState.initial() {
    return UserSearchState(
      users: [],
      isLoading: false,
      hasError: false,
    );
  }

  factory UserSearchState.loading() {
    return UserSearchState(
      users: [],
      isLoading: true,
      hasError: false,
    );
  }

  factory UserSearchState.success(List<User> users) {
    return UserSearchState(
      users: users,
      isLoading: false,
      hasError: false,
    );
  }

  factory UserSearchState.error() {
    return UserSearchState(
      users: [],
      isLoading: false,
      hasError: true,
    );
  }

  @override
  String toString() =>
      'UserSearchState {users: ${users.toString()}, isLoading: $isLoading, hasError: $hasError }';
}