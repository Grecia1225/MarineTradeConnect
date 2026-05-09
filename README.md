import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'role_selection_screen.dart';

class SignupScreen extends StatefulWidget {
const SignupScreen({super.key});

@override
State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
final _emailController = TextEditingController();
final _passwordController = TextEditingController();
final _auth = FirebaseAuth.instance;
bool _loading = false;

void _signup() async {
setState(() {
_loading = true;
});
try {
await _auth.createUserWithEmailAndPassword(
email: _emailController.text.trim(),
password: _passwordController.text.trim(),
);
Navigator.pushReplacement(
context,
MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
);
} on FirebaseAuthException catch (e) {
String message = e.message ?? "Signup failed";
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message)),
);
} finally {
setState(() {
_loading = false;
});
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Sign Up')),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
children: [
TextField(
controller: _emailController,
decoration: const InputDecoration(labelText: 'Email'),
),
const SizedBox(height: 10),
TextField(
controller: _passwordController,
decoration: const InputDecoration(labelText: 'Password'),
obscureText: true,
),
const SizedBox(height: 20),
_loading
? const CircularProgressIndicator()
: ElevatedButton(
onPressed: _signup,
child: const Text('Sign Up'),
),
const SizedBox(height: 10),
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Already have an account? Log in'),
),
],
),
),
);
}
}