import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meet_in_ground/Models/Post.dart';
import 'package:meet_in_ground/util/Services/mobileNo_service.dart';
import 'package:meet_in_ground/widgets/BottomNavigationScreen.dart';
import 'package:meet_in_ground/widgets/Confirmation_Dialog.dart';
import 'package:meet_in_ground/widgets/Loader.dart';
import 'package:meet_in_ground/widgets/NoDataFoundWidget.dart';
import 'package:meet_in_ground/widgets/SportSelectDialog.dart';
import 'package:meet_in_ground/widgets/post_widget.dart';
import 'package:meet_in_ground/constant/sports_names.dart';
import 'package:meet_in_ground/constant/themes_service.dart';
import 'package:http/http.dart' as http;

class Favorites extends StatefulWidget {
  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  Future<List<Post>>? futurePosts;
  final TextEditingController _searchController = TextEditingController();
  bool isAscending = true;
  String selectedSport = '';
  Map<String, bool> showMoreMap = {};
  String? currentMobileNumber;

  // final NativeAdsController nativeAdController = Get.put(NativeAdsController());

  @override
  void initState() {
    super.initState();
    // nativeAdController.loadAd();
    initializeData().then((mobileNumber) {
      if (mounted) {
        setState(() {
          currentMobileNumber = mobileNumber!;
          futurePosts = fetchPosts();
        });
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  Future<String?> initializeData() async {
    try {
      String? number = await MobileNo.getMobilenumber();
      return number;
    } catch (exception) {
      print(exception);
    }
    return null;
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

  Future<List<Post>> fetchPosts({String? query}) async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    print(currentMobileNumber.toString());
    final url = query != null && query.isNotEmpty
        ? '$Base_url/user/viewFavorites/$currentMobileNumber?search=$query'
        : '$Base_url/user/viewFavorites/$currentMobileNumber';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      List<Post> posts =
          jsonResponse.map((post) => Post.fromJson(post)).toList();

      if (selectedSport.isNotEmpty) {
        posts = posts.where((post) => post.sport == selectedSport).toList();
      }
      posts.sort((a, b) {
        DateTime dateA = a.createdAt != null
            ? DateTime.parse(a.createdAt!)
            : DateTime.fromMillisecondsSinceEpoch(0);
        DateTime dateB = b.createdAt != null
            ? DateTime.parse(b.createdAt!)
            : DateTime.fromMillisecondsSinceEpoch(0);
        return isAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });

      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> deleteFav(String postId) async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    final String apiUrl = '$Base_url/user/removeFavorites';

    final Map<String, dynamic> requestData = {
      'id': postId,
      'phoneNumber': currentMobileNumber,
    };

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        futurePosts = fetchPosts();
      });
      Fluttertoast.showToast(
        msg: responseData['message'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: responseData['error'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> toggleFavorite(String postId) async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    final String apiUrl = '$Base_url/user/addFavorites';
    print(postId);

    final Map<String, dynamic> requestData = {
      'id': postId,
      'phoneNumber': currentMobileNumber,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        futurePosts = fetchPosts();
      });
      Fluttertoast.showToast(
        msg: responseData['message'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: responseData['error'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> deleteRequest(String postId) async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    final String apiUrl = '$Base_url/post/removeRequest/$currentMobileNumber';

    final Map<String, dynamic> requestData = {
      'postId': postId,
    };

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        futurePosts = fetchPosts();
      });
      Fluttertoast.showToast(
        msg: responseData['message'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: responseData['error'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> toggleRequest(String postId) async {
    String Base_url = dotenv.get("BASE_URL", fallback: null);
    final String apiUrl = '$Base_url/post/makeRequestPost/$currentMobileNumber';
    print(postId);

    final Map<String, dynamic> requestData = {
      'postId': postId,
    };

    final response = await http.patch(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      setState(() {
        futurePosts = fetchPosts();
      });
      Fluttertoast.showToast(
        msg: responseData['message'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: responseData['error'] ?? "",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
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
        notificationPredicate: (notification) => false,
        backgroundColor: ThemeService.background,
        automaticallyImplyLeading: false,
        title: Text(
          'Favorites',
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
              FutureBuilder<List<Post>>(
                future: futurePosts,
                builder: (context, snapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: snapshot.hasData && snapshot.data!.isNotEmpty
                              ? const EdgeInsets.only(left: 10)
                              : const EdgeInsets.symmetric(horizontal: 20),
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
                      Visibility(
                        visible: snapshot.hasData && snapshot.data!.isNotEmpty,
                        child: Column(
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
                      ),
                      Visibility(
                        visible: snapshot.hasData && snapshot.data!.isNotEmpty,
                        child: IconButton(
                          icon: Icon(
                            selectedSport.isEmpty
                                ? Icons.filter_alt
                                : Icons.filter_alt_off,
                          ),
                          color: ThemeService.primary,
                          onPressed: () {
                            if (selectedSport.isEmpty) {
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
                            } else {
                              setState(() {
                                selectedSport = '';
                                futurePosts = fetchPosts();
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              FutureBuilder<List<Post>>(
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
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => BottomNavigationScreen(currentIndex: 0),
            ),
          );
          return false;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              futurePosts = fetchPosts();
              _searchController.text = "";
            });
          },
          child: FutureBuilder<List<Post>>(
            future: futurePosts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Loader());
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(child: NoDataFoundWidget());
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Post post = snapshot.data![index];
                    bool isShowMore = showMoreMap[post.id] ?? false;

                    return Post_Widget(
                      userName: post.userName,
                      placeOfMatch: post.placeOfMatch,
                      likes: post.likes,
                      comments: post.comments,
                      betAmount: post.betAmount,
                      id: post.id,
                      image: post.image,
                      postOwnerImage: post.postOwnerImage,
                      matchDate: post.matchDate,
                      matchDetails: post.matchDetails,
                      phoneNumber: post.phoneNumber,
                      sport: post.sport,
                      status: post.status,
                      createdAt: post.createdAt,
                      isShowMore: isShowMore,
                      onToggleShowMore: _toggleShowMore,
                      isFavorite: post.favorites.any((favorite) =>
                          favorite['phoneNumber'] ==
                          "+91" + currentMobileNumber!),
                      onDeleteFav: () => deleteFav(post.id),
                      onFavoriteToggle: () => toggleFavorite(post.id),
                      isRequest: post.requests.any((requuest) =>
                          requuest['phoneNumber'] ==
                          "+91" + currentMobileNumber!),
                      onDeleteRequest: () => showConfirmationDialog(
                          context,
                          () => deleteRequest(post.id),
                          "Do you want Delete this Post Request?",
                          Colors.red.shade400),
                      onRequestToggle: () => showConfirmationDialog(
                          context,
                          () => toggleRequest(post.id),
                          "Do you want Request this Post?",
                          Colors.green.shade400),
                      currentMobileNumber: "+91" + currentMobileNumber!,
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
