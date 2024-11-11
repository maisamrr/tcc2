import 'dart:convert';
import 'package:app/const.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart'; 
import 'package:app/store/user_store.dart';
import 'package:app/services/user_service.dart';

Future<String> fetchGoogleApiKey() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.fetchAndActivate();
  return remoteConfig.getString('GOOGLE_API_KEY');
}

class Recipe {
  final String title;
  final List<String> items;
  final String servings;
  final List<String> prepare;

  Recipe({
    required this.title,
    required this.items,
    required this.servings,
    required this.prepare,
  });
}


class RecipeDetails extends StatefulWidget {
  final String title;
  final List<String> items;
  final String servings;
  final List<String> prepare;

  const RecipeDetails({
    super.key,
    required this.title,
    required this.items,
    required this.servings,
    required this.prepare,
  });

  @override
  _RecipeDetailsState createState() => _RecipeDetailsState();
}

class _RecipeDetailsState extends State<RecipeDetails> {
  YoutubePlayerController? _youtubePlayerController;
  bool _isFavorited = false;
  late UserStore userStore;
  final UserService userService = UserService();

  @override
  @override
  void initState() {
    super.initState();
    userStore = Provider.of<UserStore>(context, listen: false);
    _loadYoutubeVideo();

    userStore.loadFavoriteRecipes().then((_) => _loadFavoriteStatus());
  }

  Future<void> _loadYoutubeVideo() async {
    final videoId = await fetchYoutubeVideoId(widget.title);
    if (videoId != null) {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          showLiveFullscreenButton: false,
          hideControls: false
        ),
      )..addListener(() {
    if (_youtubePlayerController!.value.isFullScreen) {
      _youtubePlayerController!.toggleFullScreenMode();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  });
      setState(() {});
    }
  }

  Future<void> _loadFavoriteStatus() async {
    setState(() {
      _isFavorited = userStore.favoriteRecipes.contains(widget.title);
    });

    print("teste");
  }

  Future<void> _toggleFavorite() async {
    await userStore.toggleFavoriteRecipe(widget.title);
    
    setState(() {
      _isFavorited = userStore.favoriteRecipes.contains(widget.title);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorited ? 'Receita adicionada aos favoritos!' : 'Receita removida dos favoritos!',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<String?> fetchYoutubeVideoId(String query) async {
    final googleApiKey = await fetchGoogleApiKey();

    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&maxResults=1&key=$googleApiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'].isNotEmpty) {
        return data['items'][0]['id']['videoId'];
      }
    }
    return null;
  }

  @override
  void dispose() {
    _youtubePlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellowColor,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                child: GestureDetector(
                  child: Icon(
                    Icons.arrow_back,
                    size: 32,
                    color: darkGreyColor,
                  ),
                  onTap: () {
                     Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: darkGreyColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleFavorite,
                      child: Icon(
                        _isFavorited ? Icons.bookmark : Icons.bookmark_add_outlined,
                        size: 32,
                        color: darkGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48.0),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: backgroundIdColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingredientes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PP Neue Montreal',
                              color: darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.items.length,
                            itemBuilder: (context, index) {
                              return Text(
                                widget.items[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  color: darkGreyColor,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                color: lightGreyColor,
                                thickness: 1,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rendimento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PP Neue Montreal',
                              color: darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.servings,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Inter',
                              color: darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Modo de preparo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PP Neue Montreal',
                              color: darkGreyColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.prepare.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  widget.prepare[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    color: darkGreyColor,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          if (_youtubePlayerController != null)
                            Column(
                              children: [
                                Text(
                                  'Vídeo de instruções',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'PP Neue Montreal',
                                    color: darkGreyColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                YoutubePlayer(
                                  controller: _youtubePlayerController!,
                                  showVideoProgressIndicator: true,
                                ),
                              ],
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
