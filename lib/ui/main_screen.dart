import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_db/bloc/bloc.dart';
import 'package:test_db/bloc/events.dart';
import 'package:test_db/bloc/states.dart';
import 'package:test_db/model/user.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<UsersBloc>(context).add(LoadUsersEvent());
    // BlocBuilder, BlocConsumer
    return BlocListener<UsersBloc, UsersState>(
      listener: (BuildContext context, state) {
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _showAddUserDialog,
              child: const Text('Add User'),
            ),
            ElevatedButton(
              onPressed: () {
                _showUsersDialog();
                },
              child: const Text('Print users'),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _showAddUserDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        var nameController = TextEditingController();
        var ageController = TextEditingController();
        return AlertDialog(
          title: Text('Add user'),
          content: Column(
            children: <Widget>[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(labelText: 'Age'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Send them to your email maybe?
                _addUser(nameController.text, int.parse(ageController.text));
                Navigator.pop(context);
              },
              child: Text('Send'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUsersDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return _outputUsersInTable();
        });
  }

  Widget _outputUsersInTable() {
    List<Text> tableCells = [];
    Table table = Table(children: [],);
    UsersState state = BlocProvider.of<UsersBloc>(context).state;
    if (state is UsersLoadedState) {
      table.children.add(
        TableRow(children: [
          Text("ID"),
          Text("Name"),
          Text("Age"),
        ]),
      );
      state.users.sort((User a, User b) {return a.name.compareTo(b.name);});
      for (User user in state.users) {
        tableCells.add(Text("${user.id}"));
        tableCells.add(Text(user.name));
        tableCells.add(Text("${user.age}"));
      }
      table.children.add(
        TableRow(children: tableCells)
      );
    }
    return AlertDialog(
      title: const Text("Users"),
      content: SingleChildScrollView(
        child: table,
      ),
      actions: [
        TextButton(
          child: const Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _addUser(String strName, int iAge) {
    final bloc = BlocProvider.of<UsersBloc>(context);
    bloc.add(
      AddUserEvent(
        User(
          name: strName,
          age: iAge,
        ),
      ),
    );
    bloc.add(LoadUsersEvent());
  }
}
