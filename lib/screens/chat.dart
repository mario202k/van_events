import 'dart:async';
import 'package:async/async.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/models/user.dart';
import 'package:vanevents/routing/route.gr.dart';
import 'package:vanevents/services/firestore_database.dart';
import 'package:vanevents/shared/topAppBar.dart';


class Chat extends StatefulWidget {
  final GlobalKey<InnerDrawerState> innerDrawerKey;

  Chat(this.innerDrawerKey);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  Stream<List<List<User>>> friendUser;
  List<User> users = List<User>();

  @override
  void dispose() {
    if(friendUser != null){
      friendUser = null;
    }


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    friendUser = StreamZip([db.usersStream1(), db.usersStream2()]);
    print('Chat!!!!!!!');
    return Scaffold(
        body: Container(
      color: Theme.of(context).colorScheme.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight),
              child: Column(children: <Widget>[
                TopAppBar(
                    'Chat',
                    true,
                    () => widget.innerDrawerKey.currentState.toggle(),
                    constraints.maxWidth),
                StreamBuilder<List<List<User>>>(
                  stream: friendUser,
                  //qui ont deja discuter
                  initialData: [],
                  builder: (context, snapshot) {
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

                    users.clear();
                    users.addAll(snapshot.data[0]);
                    users.addAll(snapshot.data[1]);

                    return users.isNotEmpty
                        ? ListView.separated(
                            shrinkWrap: true,
                            separatorBuilder: (context, index) => Divider(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  thickness: 1,
                                ),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final User userFriend = users.elementAt(index);

                              Stream<Message> lastMsg = db.getLastChatMessage(
                                  userFriend.chatId[db.uid]);
                              Stream<List<Message>> msgNonLu =
                                  db.getChatMessageNonLu(
                                      userFriend.chatId[db.uid]);

                              return StreamBuilder<Message>(
                                  stream: lastMsg,
                                  builder: (context, snapshot) {
                                    Message message;
                                    String day = '', month = '';
                                    if (!snapshot.hasData) {
                                      message = Message(
                                          message: 'aucun message', type: -1);
                                    } else {
                                      message = snapshot.data;

                                      if (message == null) return ListTile();

                                      day = message.date.day
                                                  .toString()
                                                  .length ==
                                              1
                                          ? '0${message.date.day.toString()}'
                                          : '${message.date.day.toString()}';

                                      month = message.date.month
                                                  .toString()
                                                  .length ==
                                              1
                                          ? '0${message.date.month.toString()}'
                                          : '${message.date.month.toString()}';
                                    }

                                    return ListTile(
                                      title: Text(
                                        userFriend.nom,
                                        style: Theme.of(context)
                                            .textTheme
                                            .display1
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                      subtitle: message.type == 0
                                          ? Text(
                                              message.message,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            )
                                          : message.type == 1
                                              ? Row(
                                                  children: <Widget>[
                                                    Icon(FontAwesomeIcons
                                                        .photoVideo),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text('Photo')
                                                  ],
                                                )
                                              : message.type == 2
                                                  ? Row(
                                                      children: <Widget>[
                                                        Icon(FontAwesomeIcons
                                                            .photoVideo),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text('gif')
                                                      ],
                                                    )
                                                  : Text(
                                                      message.message,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                      onTap: () {
                                        db
                                            .creationChatRoom(userFriend.id)
                                            .then((chatId) {
                                          Navigator.of(context).pushNamed(
                                              Router.chatRoom,
                                              arguments: ChatRoomArguments(
                                                  myId: db.uid,
                                                  nomFriend: userFriend.nom,
                                                  imageFriend:
                                                      userFriend.imageUrl,
                                                  chatId: chatId,
                                                  friendId: userFriend.id));
//                                      Navigator.push(
//                                          context,
//                                          MaterialPageRoute(
//                                              builder: (context) => ChatRoom(
//                                                  db.uid,
//                                                  userFriend.nom,
//                                                  userFriend.imageUrl,
//                                                  chatId,
//                                                  userFriend.id)));
                                        });
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(userFriend.imageUrl),
                                        radius: 25,
                                      ),
                                      trailing: Column(
                                        children: <Widget>[
                                          message.type != -1
                                              ? Text(
                                                  //si c'est aujourh'hui l'heure sinon date
                                                  '${DateTime.now().day != message.date.day ? '$day/$month/${message.date.year}' : '${message.date.hour.toString().length == 1 ? 0 : ''}${message.date.hour}:${message.date.minute.toString().length == 1 ? 0 : ''}${message.date.minute}'}')
                                              : SizedBox(),
                                          StreamBuilder(
                                              stream: msgNonLu,
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return SizedBox();
                                                }

                                                int i = 0;

                                                snapshot.data.documents
                                                    .forEach((doc) {
                                                  i++;
                                                });

                                                return i != 0
                                                    ? Badge(
                                                        badgeContent:
                                                            Text('$i'),
                                                        child: Icon(
                                                            Icons.markunread),
                                                      )
                                                    : SizedBox();
                                              }),
                                        ],
                                      ),
                                    );
                                  });
                            })
                        : Center(
                            child: Text('Pas de conversation'),
                          );
                  },
                ),
              ]),
            ),
          );
        },
      ),
    ));
  }
}
