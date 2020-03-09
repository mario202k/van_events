import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:platform_alert_dialog/platform_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:vanevents/models/message.dart';
import 'package:vanevents/screens/full_photo.dart';
import 'package:vanevents/services/firestore_database.dart';

class ChatRoom extends StatefulWidget {
  final String myId;
  final String nomFriend;
  final String imageFriend;
  final String chatId;
  final String friendId;

  ChatRoom(
      this.myId, this.nomFriend, this.imageFriend, this.chatId, this.friendId);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with TickerProviderStateMixin {
  List<Message> _messages = List<Message>();
  DateTime _lastTimestamp;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  TextEditingController _textEditingController = TextEditingController();

  Stream<List<Message>> streamListMessage;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    streamListMessage = db.getChatMessages(widget.chatId);
    return Scaffold(
        appBar: AppBar(
            elevation: 0.4,
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
            title: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 5, 10, 0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.imageFriend),
                    backgroundColor: Colors.grey[200],
                    maxRadius: 22,
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.nomFriend,
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        'En ligne',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            )),
        body: Column(children: [
          Flexible(
            child: StreamBuilder<List<Message>>(
              stream: streamListMessage,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary)),
                  );
                } else if (snapshot.hasError) {
                  print('Erreur de connection${snapshot.error.toString()}');
                  db.showSnackBar(
                      'Erreur de connection${snapshot.error.toString()}',
                      context);
                  print('Erreur de connection${snapshot.error.toString()}');
                  return Center(
                    child: Text(
                      'Erreur de connection',
                      style: Theme.of(context).textTheme.display1,
                    ),
                  );
                } else if (!snapshot.hasData) {
                  print("pas data");
                  return Center(
                    child: Text('Pas de message'),
                  );
                }

                if (_lastTimestamp == null) {
                  _messages.addAll(snapshot.data);
                  if (_messages.isNotEmpty)
                    _lastTimestamp = _messages.first.date;
                } else {
                  db
                      .getLastChatMessagesChatRoom(
                          widget.chatId, _lastTimestamp)
                      .then((newMsg) {
                    if (newMsg != null) {
                      _messages.insert(0, newMsg);
                      _listKey.currentState
                          .insertItem(0, duration: Duration(milliseconds: 500));

                      _lastTimestamp = newMsg.date;
                    }
                  });
                }

                print(_lastTimestamp);

                return _messages.isNotEmpty
                    ? AnimatedList(
                        initialItemCount: _messages.length,
                        key: _listKey,
                        padding: EdgeInsets.all(8.0),
                        reverse: true,
                        itemBuilder: (BuildContext context, int index,
                            Animation<double> animation) {
                          return SizeTransition(
                              axis: Axis.vertical,
                              sizeFactor: animation,
                              child: isAnotherDay(index, _messages)
                                  ? Column(
                                      children: <Widget>[
                                        Text(
                                          isToday(_messages[index].date)
                                              ? 'Aujourd\'hui'
                                              : isYesterday(
                                                      _messages[index].date)
                                                  ? 'Hier'
                                                  : ' ${day(_messages[index].date.weekday)} ${_messages[index].date.day} ${month(_messages[index].date.month)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .display1,
                                        ),
                                        ChatMessageListItem(
                                            _messages[index],
                                            widget.myId ==
                                                _messages[index].idFrom,
                                            widget.chatId)
                                      ],
                                    )
                                  : ChatMessageListItem(
                                      _messages[index],
                                      widget.myId == _messages[index].idFrom,
                                      widget.chatId));
                        },
                      )
                    : Center(
                        child: Text('Pas de message'),
                      );
              },
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 2,
          ),
          Container(
              decoration: BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(db)),
        ]));
  }

  String day(int week) {
    switch (week) {
      case DateTime.monday:
        return 'Lundi';
      case DateTime.tuesday:
        return 'Mardi';
      case DateTime.wednesday:
        return 'Mercredi';
      case DateTime.thursday:
        return 'Jeudi';
      case DateTime.friday:
        return 'Vendredi';
      case DateTime.saturday:
        return 'Samedi';
      case DateTime.sunday:
        return 'Dimanche';
    }
  }

  String month(int month) {
    switch (month) {
      case DateTime.january:
        return 'Janvier';
      case DateTime.february:
        return 'Février';
      case DateTime.march:
        return 'Mars';
      case DateTime.april:
        return 'Avril';
      case DateTime.may:
        return 'Mai';
      case DateTime.june:
        return 'Juin';
      case DateTime.july:
        return 'Juillet';
      case DateTime.august:
        return 'Août';
      case DateTime.september:
        return 'Septembre';
      case DateTime.october:
        return 'Octobre';
      case DateTime.november:
        return 'Novembre';
      case DateTime.december:
        return 'Décembre';
    }
  }

  bool isAnotherDay(int index, List<Message> messages) {
    if (index == messages.length - 1) {
      return true;
    }

    bool b = false;

    if (index > 0 && index < messages.length - 1) {
      if (messages[index].date.day > messages[index + 1].date.day) {
        b = true;
      }
    }

    return b;
  }

  bool isToday(DateTime date) {
    bool b = false;

    if (date.day == DateTime.now().day) {
      b = true;
    }
    print(date.day);

    return b;
  }

  bool isYesterday(DateTime date) {
    bool b = false;

    if (date.day + 1 == DateTime.now().day) {
      b = true;
    }
    print(date.day);

    return b;
  }

  Future _getImageCamera(FirestoreDatabase db) async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    String path = image.path;
    print(path.substring(path.lastIndexOf('/') + 1));
    db.uploadImageChat(image, widget.chatId, widget.myId, widget.friendId);
  }

  Future _getImageGallery(FirestoreDatabase db) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    String path = image.path;
    print(path.substring(path.lastIndexOf('/') + 1));
    db.uploadImageChat(image, widget.chatId, widget.myId, widget.friendId);
  }

  Widget _buildTextComposer(FirestoreDatabase db) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(children: [
          Container(
            child: IconButton(
              icon: Icon(Icons.photo),
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return PlatformAlertDialog(
                      title: Text(
                        'Source?',
                        style: Theme.of(context).textTheme.display1,
                      ),
                      actions: <Widget>[
                        PlatformDialogAction(
                          child: Text(
                            'Caméra',
                            style: Theme.of(context)
                                .textTheme
                                .display1
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            _getImageCamera(db);
                          },
                        ),
                        PlatformDialogAction(
                          child: Text(
                            'Galerie',
                            style: Theme.of(context)
                                .textTheme
                                .display1
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          //actionType: ActionType.,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _getImageGallery(db);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            child: IconButton(
              icon: Icon(Icons.gif),
              onPressed: () {
                pickGif(context, db);
              },
            ),
          ),
          Flexible(
            child: TextField(
              controller: _textEditingController,
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: Colors.black),
//              onChanged: _handleMessageChanged,
              decoration:
                  InputDecoration.collapsed(hintText: 'Saisir un message'),
              maxLines: null,
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () =>
                      _sendMessage(_textEditingController.text, db))),
        ]));
  }

  void pickGif(BuildContext context, FirestoreDatabase db) async {
    final gif = await GiphyPicker.pickGif(
        context: context, apiKey: 'nZXOSODAIyJlsmNBMXzz55JvV5f8kd0D');

    if (gif != null) {
      db.sendMessage(widget.chatId, widget.myId, gif.images.original.url,
          widget.friendId, 2);
    }
  }

  void _sendMessage(String text, FirestoreDatabase db) {
    if (text.trim() != '') {
      _textEditingController.clear();
      db
          .sendMessage(widget.chatId, widget.myId, text, widget.friendId, 0)
          .catchError((err) {
        _textEditingController.text = text;
      });
    } else {
      print('Text vide ou null');
    }
  }
}

class ChatMessageListItem extends StatefulWidget {
  final Message message;
  final bool isMe;
  final String chatId;

  ChatMessageListItem(this.message, this.isMe, this.chatId);

  @override
  _ChatMessageListItemState createState() => _ChatMessageListItemState();
}

class _ChatMessageListItemState extends State<ChatMessageListItem> {
  bool isReceive = false;
  bool isRead = false;
  String id;

  Widget build(BuildContext context) {
    final db = Provider.of<FirestoreDatabase>(context, listen: false);
    id = widget.message.id; //Car l'animated list reconstruit que le build

    return Container(
      margin: EdgeInsets.only(top: 4, bottom: 4),
      child: widget.message.type == 0 //message text
          ? Row(
              mainAxisAlignment:
                  widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                widget.isMe
                    ? StreamBuilder<Message>(
                        //pour écouté si le message est lu
                        stream: db.getChatMessageStream(widget.chatId, id),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            Message message = snapshot.data;
                            int state = message.state;

                            isReceive = false;
                            isRead = false;

                            switch (state) {
                              case 1:
                                isReceive = true;
                                break;
                              case 2:
                                isRead = true;
                                isReceive = true;
                            }
                          }

                          return Icon(
                            IconData(isReceive ? 0xf382 : 0xf3d0,
                                fontFamily: "CupertinoIcons"),
                            size: 19,
                            color: isRead ? Colors.green : Colors.grey,
                          );
                        })
                    : SizedBox(),
                widget.isMe
                    ? Text(
                        //horaire
                        '${widget.message.date.hour.toString().length == 1 ? 0 : ''}${widget.message.date.hour}:${widget.message.date.minute.toString().length == 1 ? 0 : ''}${widget.message.date.minute}',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      )
                    : SizedBox(),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isMe
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: widget.isMe
                        ? BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(0),
                            bottomLeft: Radius.circular(15),
                          )
                        : BorderRadius.only(
                            topRight: Radius.circular(15),
                            topLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(0),
                          ),
                  ),
                  child: Text(
                    widget.message.message,
                    textAlign: widget.isMe ? TextAlign.end : TextAlign.start,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                !widget.isMe
                    ? Text(
                        //horaire
                        '${widget.message.date.hour.toString().length == 1 ? 0 : ''}${widget.message.date.hour}:${widget.message.date.minute.toString().length == 1 ? 0 : ''}${widget.message.date.minute}',
                        style: TextStyle(color: Colors.black, fontSize: 13),
                      )
                    : SizedBox(),
              ],
            )
          : widget.message.type == 1 //photo
              ? Container(
//            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FullPhoto(url: widget.message.message)));
                    },
                    padding: EdgeInsets.all(0),
                    child: Material(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      clipBehavior: Clip.hardEdge,
                      child: CachedNetworkImage(
                        placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.secondary),
                          ),
                          width: 200.0,
                          height: 200.0,
                          padding: EdgeInsets.all(70.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Material(
                          child: Image.asset(
                            'assets/img/img_not_available.jpeg',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                          clipBehavior: Clip.hardEdge,
                        ),
                        imageUrl: widget.message.message,
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              : Container(
                  //gif
                  child: Image.network(
                    widget.message.message,
                  ),
                ),
    );
  }
}
