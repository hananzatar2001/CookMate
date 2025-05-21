import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class YouTubeSearchPage extends StatefulWidget {
  final String query;

  const YouTubeSearchPage({super.key, required this.query});

  @override
  State<YouTubeSearchPage> createState() => _YouTubeSearchPageState();
}

class _YouTubeSearchPageState extends State<YouTubeSearchPage> {
  static const String apiKey = 'AIzaSyAn4XdXyZ-hLagS-je_kMEXw2M1afcajJ4';

  bool isLoading = true;
  String error = '';
  List videos = [];

  @override
  void initState() {
    super.initState();
    searchVideos();
  }

  Future<void> searchVideos() async {
    final url = Uri.parse(
      'https://www.googleapis.com/youtube/v3/search?part=snippet&q=${Uri.encodeComponent(widget.query)}&type=video&maxResults=10&key=$apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videos = data['items'].where((video) => video['id']?['videoId'] != null).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load videos';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the video')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YouTube Search: "${widget.query}"')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : videos.isEmpty
          ? const Center(child: Text('No videos found.'))
          : ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          final videoId = video['id']['videoId'];
          final title = video['snippet']['title'];
          final thumbnailUrl = video['snippet']['thumbnails']['default']['url'];

          return Card(
            margin: const EdgeInsets.all(8),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Image.network(thumbnailUrl),
              title: Text(title),
              onTap: () {
                final youtubeUrl = 'https://www.youtube.com/watch?v=$videoId';
                _launchURL(youtubeUrl);
              },
            ),
          );
        },
      ),
    );
  }
}
