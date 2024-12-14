import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:date_field/date_field.dart';

const MAIN_FONT_SIZE = 24;
var GLOBAL_THEME = "dark";
var scalingFactor = 1.0;

void main() {
  runApp(const DoItLaterApp());
}

class DoItLaterApp extends StatefulWidget {
  const DoItLaterApp({super.key});

  @override
  _DoItLaterAppState createState() => _DoItLaterAppState();
}

class _DoItLaterAppState extends State<DoItLaterApp> {
  List<ToDoListItem> allListItems = [];

  Future<void> addNewToDoListItem(ToDoListItem latestItem) async {
    setState(() {
      allListItems.add(latestItem);
    });

    await updateJsonFile();
  }

  Future<void> updateJsonFile() async {
    try {
      final file = File('assets/data.json');
      final jsonString = json
          .encode(allListItems.map((item) => ("${item.toJSON()}, ")).toList());
      await file.writeAsString(jsonString);
    } catch (e) {
      print(e);
    }
  }

  void reorderItems() {
    setState(() {
      allListItems.sort((a, b) => a.done ? 1 : -1);
    });
  }

  void editItem(ToDoListItem item) {
    // Add your editing logic here
  }

  void deleteItem(ToDoListItem item) {
    setState(() {
      allListItems.remove(item);
    });
  }

  @override
  void initState() {
    // final file = File('assets/data.json');
    Future.delayed(Duration.zero, () async {
      try {
        final jsonString = await rootBundle.loadString('assets/data.json');
        final jsonData = (json.decode(jsonString))["items"];

        for (var element in jsonData) {
          addNewToDoListItem(ToDoListItem.fromJSON(element));
        }
      } catch (e) {
        print(e);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Do It Later',
      theme: GLOBAL_THEME == "dark" ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => ToDoListItemListScreen(
              allListItems: allListItems,
              onAddItem: addNewToDoListItem,
              reorderItems: reorderItems,
              onEditItem: editItem,
              onDeleteItem: deleteItem,
            ),
        '/add': (context) => AddToDoItemScreen(onAddItem: addNewToDoListItem),
        '/settings': (context) => const SettingsScreen(),
        '/credits': (context) => const CreditScreen(),
      },
    );
  }
}

class ToDoListItem extends StatefulWidget {
  bool done = false;
  final String title;
  final String description;
  final DateTime deadlineDateTime;
  final String category;
  final String priority;

  ToDoListItem({
    super.key,
    required this.title,
    required this.description,
    required this.deadlineDateTime,
    required this.category,
    required this.priority,
  });

  Map<String, dynamic> toJSON() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'deadlineDateTime': deadlineDateTime.toIso8601String(),
    };
  }

  factory ToDoListItem.fromJSON(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");

    return ToDoListItem(
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      deadlineDateTime: dateFormat.parse(json['deadlineDateTime']),
    );
  }

  factory ToDoListItem.toJSON(Map<String, dynamic> json) {
    DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");

    return ToDoListItem(
      title: json['title'],
      description: json['description'],
      category: json['category'],
      priority: json['priority'],
      deadlineDateTime: dateFormat.parse(json['deadlineDateTime']),
    );
  }

  @override
  _ToDoListItemState createState() => _ToDoListItemState();
}

class _ToDoListItemState extends State<ToDoListItem> {
  bool done = false;

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: done,
                  onChanged: (bool? newValue) {
                    setState(() {
                      done = newValue ?? false;
                    });
                  },
                ),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.lightBlue[400],
                    decoration:
                        done ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ],
            ),
            Text(formatDateTime(widget.deadlineDateTime)),
            Text('Priority: ${widget.priority}'),
          ],
        ),
      ),
    );
  }
}

class ToDoListItemListScreen extends StatelessWidget {
  final List<ToDoListItem> allListItems;
  final Function(ToDoListItem) onAddItem;
  final Function reorderItems;
  final Function(ToDoListItem) onEditItem;
  final Function(ToDoListItem) onDeleteItem;

  const ToDoListItemListScreen({
    super.key,
    required this.allListItems,
    required this.onAddItem,
    required this.reorderItems,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Do It Later',
          style: TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor),
        ),
      ),
      body: ListView.builder(
        itemCount: allListItems.length,
        itemBuilder: (context, index) {
          final toDoListItemToDisplay = allListItems[index];
          return GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          toDoListItemToDisplay.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Category: ${toDoListItemToDisplay.category}"),
                        Text("Priority: ${toDoListItemToDisplay.priority}"),
                        Text(
                          "Deadline: ${formatDateTime(toDoListItemToDisplay.deadlineDateTime)}",
                        ),
                        Text(
                            "Description: ${toDoListItemToDisplay.description}"),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.edit),
                          title: const Text('Edit'),
                          onTap: () {
                            Navigator.pop(context);
                            onEditItem(toDoListItemToDisplay);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Delete'),
                          onTap: () {
                            Navigator.pop(context);
                            onDeleteItem(toDoListItemToDisplay);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: toDoListItemToDisplay,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: 10,
            bottom: 10,
            child: FloatingActionButton(
              heroTag: "addNewItem",
              onPressed: () {
                Navigator.pushNamed(context, '/add');
              },
              child: const Icon(Icons.add, size: 40),
            ),
          ),
          Positioned(
            left: 20,
            top: 25,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              heroTag: "settings",
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('profile_card.jpg'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddToDoItemScreen extends StatefulWidget {
  final Function(ToDoListItem) onAddItem;

  const AddToDoItemScreen({super.key, required this.onAddItem});

  @override
  _AddToDoItemScreenState createState() => _AddToDoItemScreenState();
}

class _AddToDoItemScreenState extends State<AddToDoItemScreen> {
  String title = "";
  String category = "";
  String description = "";
  String priority = "Low";
  DateTime deadlineDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                title = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (value) {
                description = value;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                category = value;
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Priority'),
              value: priority,
              items: ['High', 'Medium', 'Low'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  priority = newValue!;
                });
              },
            ),
            const SizedBox(height: 10),
            DateTimeFormField(
              decoration: const InputDecoration(labelText: 'Deadline Date'),
              onSaved: (DateTime? value) {
                if (value != null) {
                  deadlineDate = value;
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  ToDoListItem newItem = ToDoListItem(
                    title: title,
                    description: description,
                    deadlineDateTime: deadlineDate,
                    category: category,
                    priority: priority,
                  );
                  widget.onAddItem(newItem);
                  Navigator.pop(context);
                } else {
                  // Show a message if the title is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title cannot be empty!')),
                  );
                }
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor),
        ),
      ),
      body: const SettingsBody(),
    );
  }
}

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  bool isDarkMode = GLOBAL_THEME == "dark" ? true : false;
  double scalingFactor = 1.0;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
      GLOBAL_THEME = isDarkMode ? "dark" : "light";
      if (context.mounted) {
        final widgetState =
            context.findAncestorStateOfType<_DoItLaterAppState>();
        widgetState?.setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 100,
                  backgroundImage: AssetImage('profile_card.jpg'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "John Doe",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 1.8),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  "john@doe.com",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
          ],
        ),
        const Divider(
          height: 10,
          thickness: 1,
          indent: 5,
          endIndent: 5,
          color: Colors.grey,
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              width: 5,
            ),
            Text(
              "Dark Mode",
              style: TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.8),
            ),
            const SizedBox(
              width: 10,
            ),
            Switch(
              value: isDarkMode,
              onChanged: toggleTheme,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 3,
                ),
                Text(
                  "Help and Feedback",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.5),
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Learn More",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "FAQ",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Suggest a New Feature",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Sync",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
            const Divider(
              height: 10,
              thickness: 1,
              indent: 5,
              endIndent: 5,
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 3,
                ),
                Text(
                  "About Us",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.5),
                ),
              ],
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Privacy",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Export your Info",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 7,
                ),
                Text(
                  "Version",
                  style:
                      TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 4,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/credits');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    foregroundColor: isDarkMode
                        ? ThemeData.light().primaryColor
                        : ThemeData.dark().primaryColor,
                  ),
                  child: Text(
                    "Credits",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.6),
                  ),
                )
              ],
            ),
            const Divider(
              height: 10,
              thickness: 1,
              indent: 5,
              endIndent: 5,
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class CreditScreen extends StatelessWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Credits",
          style: TextStyle(fontSize: MAIN_FONT_SIZE * scalingFactor * 1),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/sudharshan.jpg'),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudharshan M Prabhu",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.8),
                  ),
                  Text(
                    "https://github.com/Sudharshan-3904",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.5),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/sujit.jpg'),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sujit S",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.8),
                  ),
                  Text(
                    "https://github.com/Sujit-S-2908",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.5),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/jaaswin.jpg'),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Jaaswin CKS",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.8),
                  ),
                  Text(
                    "https://github.com/JASWINCKS",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.5),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundImage: AssetImage('assets/dharshan.png'),
              ),
              const SizedBox(width: 15),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dharshan S",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.8),
                  ),
                  Text(
                    "https://github.com/shanshadow",
                    style: TextStyle(
                        fontSize: MAIN_FONT_SIZE * scalingFactor * 0.5),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
