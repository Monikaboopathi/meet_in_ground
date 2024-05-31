import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meet_in_ground/Screens/Posts/EditPosts.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';
import 'package:meet_in_ground/widgets/SportSelectDialog.dart';
import 'package:meet_in_ground/widgets/post_widget.dart';
import 'package:meet_in_ground/constant/sports_names.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;

class MyPosts extends StatefulWidget {
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  late Future<List> futurePosts;
  final TextEditingController _searchController = TextEditingController();
  bool isAscending = true;
  String selectedSport = '';
  Map<String, bool> showMoreMap = {};
  String currentMobileNumber = "";

  @override
  void initState() {
    super.initState();
    currentMobileNumber = "8072974576";
    futurePosts = fetchPosts();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      futurePosts = fetchPosts(query: _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List> fetchPosts({String? query}) async {
    final url = query != null && query.isNotEmpty
        ? 'https://bet-x-new.onrender.com/post/viewMyPosts/$currentMobileNumber?search=$query'
        : 'https://bet-x-new.onrender.com/post/viewMyPosts/$currentMobileNumber';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      List posts = [];

      for (var postJson in jsonResponse) {
        posts.add(postJson);
      }
      print(posts.isEmpty);
      if (selectedSport.isNotEmpty) {
        posts = posts.where((post) => post['sport'] == selectedSport).toList();
      }
      posts.sort((a, b) {
        DateTime dateA = a['createdAt'] != null
            ? DateTime.parse(a['createdAt'])
            : DateTime.fromMillisecondsSinceEpoch(0);
        DateTime dateB = b['createdAt'] != null
            ? DateTime.parse(b['createdAt'])
            : DateTime.fromMillisecondsSinceEpoch(0);
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });

      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  void _toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      futurePosts = fetchPosts(query: _searchController.text);
    });
  }

  void _toggleShowMore(String postId) {
    setState(() {
      showMoreMap[postId] = !(showMoreMap[postId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeService.background,
      appBar: AppBar(
        backgroundColor: ThemeService.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ThemeService.textColor, size: 35),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 2),
            ),
          ),
        ),
        title: Text(
          'My Posts',
          style: TextStyle(
            color: ThemeService.textColor,
            fontFamily: 'Billabong',
            fontSize: 25,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 70),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FutureBuilder<List>(
                future: futurePosts,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            height: 40,
                            child: TextField(
                              controller: _searchController,
                              style: TextStyle(color: ThemeService.textColor),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle:
                                    TextStyle(color: ThemeService.textColor),
                                suffixIcon: _searchController.text.isEmpty
                                    ? IconButton(
                                        icon: Icon(Icons.search),
                                        color: ThemeService.textColor,
                                        onPressed: _onSearchChanged,
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.cancel),
                                        color: ThemeService.textColor,
                                        onPressed: () {
                                          _searchController.text = "";
                                          setState(() {
                                            futurePosts = fetchPosts();
                                          });
                                        },
                                      ),
                                focusColor: ThemeService.primary,
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ThemeService.primary),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8.0),
                              ),
                              onSubmitted: (value) => _onSearchChanged(),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAscending ? "asc" : "desc",
                                style: TextStyle(
                                  fontSize: 6,
                                  color: ThemeService.primary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(Icons.swap_vert),
                            color: ThemeService.primary,
                            onPressed: _toggleSortOrder,
                            iconSize: 30,
                          ),
                        ],
                      ),
                      selectedSport.isEmpty
                          ? IconButton(
                              icon: Icon(Icons.filter_alt),
                              color: ThemeService.primary,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SportSelectDialog(
                                      sportNames: sportNames,
                                      selectedSport: selectedSport,
                                      onSportSelected: (selectedSport) {
                                        if (selectedSport.isNotEmpty) {
                                          setState(() {
                                            this.selectedSport = selectedSport;
                                            futurePosts = fetchPosts();
                                          });
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            )
                          : IconButton(
                              onPressed: () {
                                selectedSport = "";
                                setState(() {
                                  selectedSport = "";
                                  futurePosts = fetchPosts();
                                });
                              },
                              color: ThemeService.primary,
                              icon: Icon(Icons.filter_alt_off))
                    ],
                  );
                },
              ),
              FutureBuilder<List>(
                future: futurePosts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Container();
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${snapshot.data!.length}",
                            style: TextStyle(
                              color: ThemeService.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            "result${snapshot.data!.length > 1 ? "s" : ""} found",
                            style: TextStyle(
                              color: ThemeService.placeHolder,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            futurePosts = fetchPosts();
            _searchController.text = "";
          });
        },
        child: FutureBuilder<List>(
          future: futurePosts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Loader());
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return Center(child: NoDataFoundWidget());
            } else {
              List<dynamic>? postData = snapshot.data;
              return ListView.builder(
                itemCount: postData!.length,
                itemBuilder: (context, index) {
                  var post = postData[index];

                  bool isShowMore = showMoreMap[post['_id']] ?? false;

                  return Post_Widget(
                      userName: post['userName'],
                      placeOfMatch: post['placeOfMatch'],
                      likes: 0,
                      comments: post['requests'].length,
                      betAmount: post['betAmount'],
                      id: post['_id'],
                      image: post['image'] ?? "r",
                      postOwnerImage: post['postOwnerImage'],
                      matchDate: post['matchDate'],
                      matchDetails: post['matchDetails'],
                      phoneNumber: post['phoneNumber'],
                      sport: post['sport'],
                      status: post['status'],
                      result: post['result'] == null ? "----" : post['result'],
                      createdAt: post['createdAt'],
                      isShowMore: isShowMore,
                      onToggleShowMore: _toggleShowMore,
                      isFavorite: false,
                      onDeleteFav: () => {},
                      onFavoriteToggle: () => {},
                      isRequest: false,
                      onDeleteRequest: () => {},
                      onRequestToggle: () => {},
                      currentMobileNumber: "+91" + currentMobileNumber,
                      showLMSSection: false,
                      showStatus: true,
                      showRequests: true,
                      onEditPost: () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      EditPost(postId: post["_id"])),
                            )
                          },
                      onDeletePost: () => {});
                },
              );
            }
          },
        ),
      ),
    );
  }
}
