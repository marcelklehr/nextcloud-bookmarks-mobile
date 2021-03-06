import 'package:bookmarks/controllers/BookmarkController.dart';
import 'package:bookmarks/abstractions/AuthenticatedView.dart';
import 'package:bookmarks/models/Bookmark.dart';
import 'package:bookmarks/views/CenteredCard.dart';
import 'package:bookmarks/widgets/HomeWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BookmarkAction { EDIT, DELETE, SHARE }

class BookmarkListView
    extends AuthenticatedView<HomeWidget, BookmarkController> {
  const BookmarkListView(state, {Key key}) : super(state, key: key);

  @override
  Widget doBuild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bookmarks"),
      ),
      body: RefreshIndicator(
        onRefresh: state.retrieveBookmarks,
        child: Center(
          child: Builder(
            builder: (context) {
              if (state.bookmarks == null) {
                state.retrieveBookmarks();
                return CircularProgressIndicator();
              } else if (state.bookmarks.length == 0) {
                return _noBookmarksFound();
              }

              return _bookmarksList();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Add bookmark',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView _bookmarksList() {
    return ListView(
      controller: ScrollController(),
      physics: AlwaysScrollableScrollPhysics(),
      children: _rows(),
    );
  }

  CenteredCard _noBookmarksFound() {
    return CenteredCard(
      child: Column(children: [
        Padding(
          padding: EdgeInsets.all(8),
          child: SvgPicture.asset("assets/whale.svg", height: 50),
        ),
        Text(
          "You don't have any bookmarks",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16.0, 0.0, 8.0),
          child: TextButton(
            onPressed: () {
              state.resetBookmarks();
              state.retrieveBookmarks();
            },
            child: Text('Refresh'),
          ),
        ),
      ]),
    );
  }

  List<Widget> _rows() {
    List<Widget> result = List();
    assert(state.bookmarks != null);
    for (Bookmark bookmark in state.bookmarks) {
      result.add(
        Card(
          elevation: 2,
          child: InkWell(
            onTap: () {
              state.launchInBrowser(bookmark.url);
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ListTile(
                    title: Text("${bookmark.title}"),
                    subtitle: Text(
                        "${bookmark.description != "" ? bookmark.description : bookmark.url}"),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                _contextMenu(bookmark),
              ],
            ),
          ),
        ),
      );
    }

    return result;
  }

  Widget _contextMenu(Bookmark bookmark) {
    return PopupMenuButton<BookmarkAction>(
      elevation: 5,
      onSelected: (BookmarkAction action) {
        switch (action) {
          case BookmarkAction.EDIT:
            // open edit view
            break;
          case BookmarkAction.SHARE:
            // open share view
            break;
          case BookmarkAction.DELETE:
            // make sure and call controller
            state.delete(bookmark);
            break;
        }
      },
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<BookmarkAction>>[
          PopupMenuItem(value: BookmarkAction.EDIT, child: Text('Edit')),
          PopupMenuItem(value: BookmarkAction.SHARE, child: Text('Share')),
          PopupMenuDivider(),
          PopupMenuItem(
              value: BookmarkAction.DELETE,
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ))
        ];
      },
    );
  }
}
