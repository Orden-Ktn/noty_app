import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';
import '../main.dart';
import '../models/user.dart';
import 'login.dart';


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      // Hachez le mot de passe avec bcrypt
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      final newUser = User()
        ..username = username
        ..email = email
        ..passwordHash = passwordHash; // Stockez le hachage complet

      try {
        await isar.writeTxn(() async {
          await isar.users.put(newUser);
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inscription réussie!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Création de compte'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/auth.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.person_add, size: 60, color: Colors.blue[600]),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Nom d\'utilisateur',
                          prefixIcon: Icon(Icons.account_circle),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom d\'utilisateur';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                            : Text('Valider', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        child: Text("Vous avez déjà de compte ? Connectez-vous", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}