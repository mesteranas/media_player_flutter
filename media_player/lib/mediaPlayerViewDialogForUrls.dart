import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class MediaPlayerURLViewer extends StatefulWidget {
  var FilePath="";
  MediaPlayerURLViewer({Key?key,required this.FilePath}):super(key:key);

  @override
  State<MediaPlayerURLViewer> createState() => _MediaPlayerURLViewerState(FilePath);
}

class _MediaPlayerURLViewerState extends State<MediaPlayerURLViewer> {
  var filePath;
  late Future<void> _initializeVideoPlayerFuture;
  VideoPlayerController? _controller;
  bool _showControls = false;

  _MediaPlayerURLViewerState(this.filePath);

  @override
  void initState() {
    super.initState();
    loadMedia();
  }

  Future<void> loadMedia() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(filePath));
    _initializeVideoPlayerFuture = _controller!.initialize();
    _controller!.setLooping(true);
        _controller!.addListener(() {
      setState(() {}); // Update the slider value as the video plays
    });
    _controller!.play();
    setState(() {}); // Trigger a rebuild to show the video player
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _rewind() {
    final newPosition = _controller!.value.position - Duration(seconds: 10);
    _controller!.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _fastForward() {
    final newPosition = _controller!.value.position + Duration(seconds: 10);
    if (newPosition < _controller!.value.duration) {
      _controller!.seekTo(newPosition);
    } else {
      _controller!.seekTo(_controller!.value.duration);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Video Player'),
      ),
      body: Center(
        child: _controller != null
            ? FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the VideoPlayerController has finished initialization, use the data it provides to limit the aspect ratio of the video.
                    return GestureDetector(
                      onTap: _toggleControls,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          ),
                          if (_showControls)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Semantics(
                                      label: 'Rewind 10 seconds',
                                      hint: 'Double tap to rewind 10 seconds',
                                      child: IconButton(
                                        icon: Icon(Icons.replay_10),
                                        tooltip: 'Rewind 10 seconds',
                                        onPressed: _rewind,
                                      ),
                                    ),
                                    Semantics(
                                      label: _controller!.value.isPlaying ? 'Pause' : 'Play',
                                      hint: 'Double tap to play or pause the video',
                                      child: IconButton(
                                        icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
                                        tooltip: _controller!.value.isPlaying ? 'Pause' : 'Play',
                                        onPressed: () {
                                          setState(() {
                                            _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                                          });
                                        },
                                      ),
                                    ),
                                    Semantics(
                                      label: 'Fast forward 10 seconds',
                                      hint: 'Double tap to fast forward 10 seconds',
                                      child: IconButton(
                                        icon: Icon(Icons.forward_10),
                                        tooltip: 'Fast forward 10 seconds',
                                        onPressed: _fastForward,
                                      ),
                                    ),
                                    Semantics(label:"volume" ,
                                    child: 
                                    
Slider(
  value: _controller!.value.volume,
  onChanged: (newValue) {
    setState(() {
      _controller?.setVolume(newValue);
    });
  },
  min: 0.0,
  max: 1.0,
  divisions: 10,
  label: 'volume ${_controller!.value.volume}',
),),
Column(children: [
                                    Semantics(label:"rate" ,
                                    child: 
                                    
Slider(
  value: _controller!.value.playbackSpeed,
  onChanged: (newValue) {
    setState(() {
      _controller?.setPlaybackSpeed(newValue);
    });
  },
  min: 0.1,
  max: 2.0,
  divisions: 10,
  label: 'rate ${_controller!.value.playbackSpeed}',
),),

                                    Semantics(label:"position" ,
                                    child: 
                                    
Slider(
  value: _controller!.value.position.inSeconds.toDouble(),
  onChanged: (newValue) {
    setState(() {
    var position = Duration(seconds: newValue.toInt());
    _controller!.seekTo(position);
    });
  },
  min: 0.0,
  max: _controller!.value.duration.inSeconds.toDouble(),
  divisions: 10,
  

),)
]),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  } else {
                    // If the VideoPlayerController is still initializing, show a loading spinner.
                    return CircularProgressIndicator();
                  }
                },
              )
            : Text('Loading video...'),
      ),
    );
  }
}