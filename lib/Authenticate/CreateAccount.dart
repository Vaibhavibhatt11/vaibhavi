// import 'package:chat_app/Authenticate/Methods.dart';
// import 'package:flutter/material.dart';
//
// import '../Screens/HomeScreen.dart';
//
// class CreateAccount extends StatefulWidget {
//   @override
//   _CreateAccountState createState() => _CreateAccountState();
// }
//
// class _CreateAccountState extends State<CreateAccount> {
//   final TextEditingController _name = TextEditingController();
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
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     width: size.width / 0.5,
//                     child: IconButton(
//                       icon: Icon(Icons.arrow_back_ios),
//                       onPressed: () {},
//                     ),
//                   ),
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
//                       "Create Account to Contiue!",
//                       style: TextStyle(
//                         color: Colors.grey[700],
//                         fontSize: 20,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: size.height / 20),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 18.0),
//                     child: Container(
//                       width: size.width,
//                       alignment: Alignment.center,
//                       child: field(size, "Name", Icons.account_box, _name),
//                     ),
//                   ),
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
//                   SizedBox(height: size.height / 20),
//                   customButton(size),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Text(
//                         "Login",
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
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
//       onTap: () {
//         if (_name.text.isNotEmpty &&
//             _email.text.isNotEmpty &&
//             _password.text.isNotEmpty) {
//           setState(() {
//             isLoading = true;
//           });
//
//           createAccount(_name.text, _email.text, _password.text).then((user) {
//             if (user != null) {
//               setState(() {
//                 isLoading = false;
//               });
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => HomeScreen()),
//               );
//               print("Account Created Sucessfull");
//             } else {
//               print("Login Failed");
//               setState(() {
//                 isLoading = false;
//               });
//             }
//           });
//         } else {
//           print("Please enter Fields");
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
//           "Create Account",
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




import 'package:chat_app/Authenticate/Methods.dart';
import 'package:chat_app/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _name = TextEditingController();
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
            SizedBox(height: size.height / 12),
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            const Text(
              "Welcome",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Create an Account to Continue!",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            field("Name", Icons.account_circle, _name, false),
            const SizedBox(height: 20),
            field("Email", Icons.email, _email, false),
            const SizedBox(height: 20),
            field("Password", Icons.lock, _password, true),
            const SizedBox(height: 30),
            customButton(size),
            const SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  "Already have an account? Login",
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
        final name = _name.text.trim();
        final email = _email.text.trim();
        final password = _password.text.trim();

        if (name.isEmpty || email.isEmpty || password.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please fill all fields."),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        setState(() {
          isLoading = true;
        });

        try {
          final user = await createAccount(name, email, password);
          setState(() => isLoading = false);

          if (user != null) {
            print("Account created successfully");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) =>  HomeScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Account creation failed. Try again."),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          setState(() => isLoading = false);
          print("Error: $e");
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
          "Create Account",
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
