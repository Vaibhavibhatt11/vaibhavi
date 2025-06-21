// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'dart:io';
//
// class VoiceRecorder extends StatefulWidget {
//   final void Function(File audioFile) onSend;
//
//   const VoiceRecorder({required this.onSend, super.key});
//
//   @override
//   State<VoiceRecorder> createState() => _VoiceRecorderState();
// }
//
// class _VoiceRecorderState extends State<VoiceRecorder> {
//   FlutterSoundRecorder? _recorder;
//   bool isRecording = false;
//   String? _filePath;
//
//   @override
//   void initState() {
//     super.initState();
//     _recorder = FlutterSoundRecorder();
//     _recorder!.openRecorder();
//   }
//
//   void _startRecording() async {
//     final path = '/sdcard/Download/audio${DateTime.now().millisecondsSinceEpoch}.aac';
//     await _recorder!.startRecorder(toFile: path);
//     setState(() {
//       isRecording = true;
//       _filePath = path;
//     });
//   }
//
//   void _stopRecording() async {
//     await _recorder!.stopRecorder();
//     setState(() => isRecording = false);
//     if (_filePath != null) widget.onSend(File(_filePath!));
//   }
//
//   @override
//   void dispose() {
//     _recorder!.closeRecorder();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Icon(isRecording ? Icons.stop : Icons.mic),
//       onPressed: isRecording ? _stopRecording : _startRecording,
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecorder extends StatefulWidget {
  final void Function(File audioFile) onSend;

  const VoiceRecorder({required this.onSend, super.key});

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecorderInitialized = false;
  bool isRecording = false;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();

    await _recorder.openRecorder();
    isRecorderInitialized = true;
    setState(() {});
  }

  Future<void> _startRecording() async {
    if (!isRecorderInitialized) return;

    final path = '/sdcard/Download/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
    setState(() {
      isRecording = true;
      _filePath = path;
    });
  }

  Future<void> _stopRecording() async {
    if (!isRecorderInitialized) return;

    await _recorder.stopRecorder();
    setState(() => isRecording = false);

    if (_filePath != null) {
      final audioFile = File(_filePath!);
      widget.onSend(audioFile);
    }
  }

  @override
  void dispose() {
    if (isRecorderInitialized) {
      _recorder.closeRecorder();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isRecording ? Icons.stop : Icons.mic),
      onPressed: isRecording ? _stopRecording : _startRecording,
    );
  }
}
