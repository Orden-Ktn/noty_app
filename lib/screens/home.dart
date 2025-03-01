import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:noty_app/models/user.dart';
import '../main.dart';
import '../models/note.dart';
import 'login.dart';

  class HomeScreen extends StatefulWidget {
    final String userId;
  
    HomeScreen({required this.userId});
  
    @override
    _HomeScreenState createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    late String currentUserId;
    String? currentUsername; // Stocker le nom d'utilisateur

    @override
    void initState() {
      super.initState();
      currentUserId = widget.userId;
      _loadUsername(); // Charger le nom d'utilisateur au démarrage
    }

    Future<void> _loadUsername() async {
      final user = await isar.users.get(int.parse(currentUserId));
      setState(() {
        currentUsername = user?.username;
      });
    }
  
    void _addNote() async {
      _titleController.clear();
      _contentController.clear();
  
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Nouvelle note', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Annuler', style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez remplir tous les champs.',
                        style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }
  
                final newNote = Note()
                  ..title = _titleController.text
                  ..content = _contentController.text
                  ..userId = currentUserId;
  
                try {
                  await isar.writeTxn(() async {
                    await isar.notes.put(newNote);
                  });
  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Note enregistrée avec succès!',
                        style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green[400],
                    ),
                  );
  
                  Navigator.pop(context);
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur lors de l\'enregistrement de la note.')),
                  );
                }
              },
              child: Text('Enregistrer', style: TextStyle(color: Colors.green[400])),
            ),
          ],
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Mes notes'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog(context);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'username',
                  enabled: false,
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Text(currentUsername ?? 'Chargement...'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Déconnexion'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/home.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FutureBuilder<List<Note>>(
                  future: isar.notes
                      .filter()
                      .userIdEqualTo(currentUserId)
                      .findAll(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final notes = snapshot.data!;
                      if (notes.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Cliquez sur le bouton en bas pour ajouter une nouvelle note.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: notes.length,
                        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.blue[600]),
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return ListTile(
                            title: Text(note.title, style: TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () => _editNote(note),
                            onLongPress: () => _deleteNote(note),
                            leading: Icon(Icons.note, color: Colors.blue[400]),
                            trailing: Icon(Icons.chevron_right, color: Colors.grey),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur de chargement des notes', style: TextStyle(color: Colors.red)));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Noty, votre bloc-notes.',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNote,
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: Colors.green[400],
        ),
      );
    }
  
    void _editNote(Note note) async {
      _titleController.text = note.title;
      _contentController.text = note.content;
  
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Modifier la note', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    note.title = _titleController.text;
                    note.content = _contentController.text;
  
                    await isar.writeTxn(() async {
                      await isar.notes.put(note);
                    });
  
                    _titleController.clear();
                    _contentController.clear();
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: Text('Mettre à jour', style: TextStyle(color: Colors.orange[400])),
                ),
                TextButton(
                  onPressed: () => _confirmDeleteNote(context, note),
                  child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      );
    }
  
    void _confirmDeleteNote(BuildContext context, Note note) async {
      showDialog(
          context: context,
          builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text('Êtes-vous sûr de vouloir supprimer cette note ?'),
            actions: <Widget>[
        TextButton(
        child: Text('Non', style: TextStyle(color: Colors.red)),
      onPressed: () {
      Navigator.of(context).pop();
      },
      ),
      ElevatedButton(
      child: Text('Supprimer', style: TextStyle(color: Colors.green)),
      onPressed: () async {
      await isar.writeTxn(() async {
      await isar.notes.delete(note.id);
      });
      Navigator.of(context).pop();
      setState(() {});
      },
      ),
            ],
        );
          },
      );
    }
  
    void _deleteNote(Note note) async {
      await isar.writeTxn(() async {
        await isar.notes.delete(note.id);
      });
      setState(() {});
    }
  
    void _showLogoutDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Déconnexion'),
            content: Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                child: Text('Non', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Oui', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }