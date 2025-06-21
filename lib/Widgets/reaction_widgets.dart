// import 'package:flutter/material.dart';
//
// class ReactionWidget extends StatelessWidget {
//   final void Function(String) onReact;
//
//   const ReactionWidget({required this.onReact, super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final reactions = ["❤️", "😂", "👍", "😮", "😢"];
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: reactions.map(
//         (emoji) => IconButton(
//           icon: Text(emoji),
//           onPressed: () => onReact(emoji),
//         ),
//       ).toList(),
//     );
//   }
// }


import 'package:flutter/material.dart';

class ReactionWidget extends StatelessWidget {
  final void Function(String) onReact;

  const ReactionWidget({super.key, required this.onReact});

  @override
  Widget build(BuildContext context) {
    final List<String> reactions = ["❤️", "😂", "👍", "😮", "😢"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: reactions.map(
            (emoji) {
          return IconButton(
            tooltip: 'React with $emoji',
            onPressed: () => onReact(emoji),
            icon: Text(
              emoji,
              style: const TextStyle(fontSize: 24), // Increased emoji size
            ),
          );
        },
      ).toList(),
    );
  }
}
