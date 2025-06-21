// import 'package:chat_app/Authenticate/CreateAccount.dart';
// import 'package:chat_app/Screens/HomeScreen.dart';
// import 'package:chat_app/Authenticate/Methods.dart';
// import 'package:flutter/material.dart';
//
// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _password = TextEditingController();
//   bool isLoading = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: isLoading
//           ? Center(
//               child: Container(
//                 height: size.height / 20,
//                 width: size.height / 20,
//                 child: CircularProgressIndicator(),
//               ),
//             )
//           : SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: size.height / 20),
//                   // Container(
//                   //   alignment: Alignment.centerLeft,
//                   //   width: size.width / 0.5,
//                   //   child: IconButton(
//                   //     icon: Icon(Icons.arrow_back_ios),
//                   //     onPressed: () {},
//                   //   ),
//                   // ),
//                   SizedBox(height: size.height / 50),
//                   Container(
//                     width: size.width / 1.1,
//                     child: Text(
//                       "Welcome",
//                       style: TextStyle(
//                         fontSize: 34,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: size.width / 1.1,
//                     child: Text(
//                       "Sign In to Continue!",
//                       style: TextStyle(
//                         color: Colors.grey[700],
//                         fontSize: 25,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: size.height / 10),
//                   Container(
//                     width: size.width,
//                     alignment: Alignment.center,
//                     child: field(size, "email", Icons.account_box, _email),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 18.0),
//                     child: Container(
//                       width: size.width,
//                       alignment: Alignment.center,
//                       child: field(size, "password", Icons.lock, _password),
//                     ),
//                   ),
//                   SizedBox(height: size.height / 10),
//                   customButton(size),
//                   SizedBox(height: size.height / 40),
//                   GestureDetector(
//                     onTap: () => Navigator.of(
//                       context,
//                     ).push(MaterialPageRoute(builder: (_) => CreateAccount())),
//                     child: Text(
//                       "Create Account",
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
//
//   Widget customButton(Size size) {
//     return GestureDetector(
//       onTap: () async {
//         if (_email.text.isNotEmpty && _password.text.isNotEmpty) {
//           setState(() {
//             isLoading = true;
//           });
//
//           try {
//             final user = await logIn(_email.text, _password.text);
//
//             setState(() {
//               isLoading = false;
//             });
//
//             if (user != null) {
//               print("Login Successful");
//               // Use pushReplacement to prevent going back to login screen
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (_) => HomeScreen()),
//               );
//             } else {
//               print("Login Failed");
//               // Show error message to user
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text("Login failed. Please check your credentials."),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             }
//           } catch (e) {
//             setState(() {
//               isLoading = false;
//             });
//             print("Login Error: $e");
//             // Show error message to user
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text("An error occurred. Please try again."),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         } else {
//           print("Please fill form correctly");
//           // Show validation message to user
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("Please fill in both email and password."),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       },
//       child: Container(
//         height: size.height / 14,
//         width: size.width / 1.2,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(5),
//           color: Colors.blue,
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           "Login",
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget field(
//     Size size,
//     String hintText,
//     IconData icon,
//     TextEditingController cont,
//   ) {
//     return Container(
//       height: size.height / 14,
//       width: size.width / 1.1,
//       child: TextField(
//         controller: cont,
//         obscureText: hintText.toLowerCase() == "password", // Hide password text
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon),
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey),
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//         ),
//       ),
//     );
//   }
// }


import 'package:chat_app/Authenticate/CreateAccount.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:chat_app/Authenticate/Methods.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: isLoading
          ? Center(
        child: SizedBox(
          height: size.height / 20,
          width: size.height / 20,
          child: const CircularProgressIndicator(),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height / 10),
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Sign In to Continue!",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: size.height / 10),
            field("Email", Icons.email, _email, false),
            const SizedBox(height: 20),
            field("Password", Icons.lock, _password, true),
            SizedBox(height: size.height / 15),
            customButton(size),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  CreateAccount()),
                  );
                },
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget field(
      String hintText,
      IconData icon,
      TextEditingController controller,
      bool isPassword,
      ) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget customButton(Size size) {
    return GestureDetector(
      onTap: () async {
        final email = _email.text.trim();
        final password = _password.text.trim();

        if (email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill in both email and password."),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        setState(() {
          isLoading = true;
        });

        try {
          final user = await logIn(email, password);
          setState(() => isLoading = false);

          if (user != null) {
            print("Login Successful");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>  HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login failed. Invalid credentials."),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          setState(() => isLoading = false);
          print("Login error: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        height: size.height / 14,
        width: size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue,
        ),
        alignment: Alignment.center,
        child: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
