import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/media.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final ApiService apiService = ApiService();

  // Audio player
  final AudioPlayer audioPlayer = AudioPlayer();

  // Media received from backend
  List<Media> mediaList = [];

  // Process received from backend
  List<String> processList = [];

  // Current image/music index
  int currentIndex = 0;

  // Loading state
  bool isLoading = true;

  // Error message
  String? errorMessage;

  // Music playing or not
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();

    loadMedia();
  }

  // ==================================================
  // GET MEDIA FROM BACKEND
  // ==================================================

  Future<void> loadMedia() async {
    try {

      final data = await apiService.getMedia();

      setState(() {
        mediaList = data.data;
        processList = data.process;
        isLoading = false;
      });

      // Automatically load first song
      if (mediaList.isNotEmpty) {
        await loadMusic(0);
      }

    } catch (error) {

      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });

    }
  }

  // ==================================================
  // LOAD MUSIC
  // ==================================================

  Future<void> loadMusic(int index) async {
    try {

      // Stop previous music
      await audioPlayer.stop();

      // Load new music
      await audioPlayer.setUrl(
        mediaList[index].music,
      );

      // Automatically play
      await audioPlayer.play();

      setState(() {
        isPlaying = true;
      });

    } catch (error) {

      debugPrint(
        'Music error: $error',
      );

      setState(() {
        isPlaying = false;
      });
    }
  }

  // ==================================================
  // SWIPE
  // ==================================================

  Future<void> onPageChanged(int index) async {

    setState(() {
      currentIndex = index;
      isPlaying = false;
    });

    // Change music with image
    await loadMusic(index);
  }

  // ==================================================
  // PLAY / PAUSE
  // ==================================================

  Future<void> toggleMusic() async {

    if (isPlaying) {

      await audioPlayer.pause();

      setState(() {
        isPlaying = false;
      });

    } else {

      await audioPlayer.play();

      setState(() {
        isPlaying = true;
      });
    }
  }

  // ==================================================
  // DISPOSE
  // ==================================================

  @override
  void dispose() {

    audioPlayer.dispose();

    super.dispose();
  }

  // ==================================================
  // UI
  // ==================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'WAD_PROJECT',
        ),
      ),

      body: buildBody(),
    );
  }

  // ==================================================
  // BODY
  // ==================================================

  Widget buildBody() {

    // -----------------------------------------------
    // LOADING
    // -----------------------------------------------

    if (isLoading) {

      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // -----------------------------------------------
    // ERROR
    // -----------------------------------------------

    if (errorMessage != null) {

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // -----------------------------------------------
    // NO DATA
    // -----------------------------------------------

    if (mediaList.isEmpty) {

      return const Center(
        child: Text(
          'No media found',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      );
    }

    // -----------------------------------------------
    // MAIN SCROLL VIEW
    // -----------------------------------------------

    return SingleChildScrollView(

      child: Column(

        children: [

          const SizedBox(height: 20),

          // ==================================================
          // SWIPE IMAGE AREA
          // ==================================================

          SizedBox(

            height: 500,

            child: PageView.builder(

              itemCount: mediaList.length,

              onPageChanged: onPageChanged,

              itemBuilder: (context, index) {

                final media = mediaList[index];

                return Padding(

                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),

                  child: Column(

                    children: [

                      // --------------------------------------
                      // IMAGE
                      // --------------------------------------

                      Expanded(

                        child: ClipRRect(

                          borderRadius:
                          BorderRadius.circular(20),

                          child: Image.network(

                            media.image,

                            width: double.infinity,

                            fit: BoxFit.cover,

                            errorBuilder:
                                (context, error, stackTrace) {

                              return const Center(
                                child: Text(
                                  'Image failed to load',
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // --------------------------------------
                      // TITLE
                      // --------------------------------------

                      Text(

                        media.title,

                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // --------------------------------------
                      // POSITION
                      // --------------------------------------

                      Text(
                        '${index + 1} / ${mediaList.length}',

                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),

          // ==================================================
          // PLAY / PAUSE
          // ==================================================

          IconButton(

            iconSize: 60,

            onPressed: toggleMusic,

            icon: Icon(

              isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,

            ),
          ),

          const SizedBox(height: 20),

          // ==================================================
          // SWIPE INSTRUCTION
          // ==================================================

          const Text(
            'Swipe left or right to change media',

            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 30),

          // ==================================================
          // PROCESS HISTORY
          // ==================================================

          buildProcessHistory(),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==================================================
  // PROCESS HISTORY
  // ==================================================

  Widget buildProcessHistory() {

    return Container(

      width: double.infinity,

      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        border: Border.all(
          color: Colors.grey,
        ),

        borderRadius: BorderRadius.circular(16),

      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          // --------------------------------------------
          // TITLE
          // --------------------------------------------

          const Text(

            'PROCESS HISTORY',

            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          // --------------------------------------------
          // PROCESS LIST
          // --------------------------------------------

          if (processList.isEmpty)

            const Text(
              'No process information available.',
            )

          else

            ...processList.map(

                  (process) => Padding(

                padding: const EdgeInsets.only(
                  bottom: 10,
                ),

                child: Row(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    const Icon(
                      Icons.check_circle,
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        process,

                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}