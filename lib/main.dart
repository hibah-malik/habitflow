// Hibah Malik
// HabitFlow App

// imports flutter widgets
import 'package:flutter/material.dart';

// lets app change data to json
import 'dart:convert';

// saves data on device/browser
import 'package:shared_preferences/shared_preferences.dart';

// starts app
void main() {
  runApp(const HabitFlowApp());
}

// main app
class HabitFlowApp extends StatelessWidget {
  const HabitFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitFlow',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

// home screen class
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// home screen data
class _HomePageState extends State<HomePage> {
  // list that holds habits
  List<Map<String, dynamic>> habits = [];

  // picks color by category
  Color getCategoryColor(String category) {
    if (category == 'Health') {
      return const Color(0xFFD8F3DC);
    } else if (category == 'School') {
      return const Color(0xFFD7E3FC);
    } else if (category == 'Fitness') {
      return const Color(0xFFFFE5D9);
    } else {
      return const Color(0xFFEADCF8);
    }
  }

  // runs first when page opens
  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  // saves habit list
  Future<void> saveHabits() async {
    final prefs = await SharedPreferences.getInstance();

    String encodedData = jsonEncode(habits);

    await prefs.setString('habit_data', encodedData);
  }

  // loads saved habits
  Future<void> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();

    String? storedData = prefs.getString('habit_data');

    if (storedData != null) {
      setState(() {
        habits = List<Map<String, dynamic>>.from(jsonDecode(storedData));
      });
    }
  }

  // adds new habit
  void addHabit(Map<String, dynamic> newHabit) {
    setState(() {
      habits.add(newHabit);
    });

    saveHabits();
  }

  // updates habit
  void updateHabit(int index, Map<String, dynamic> updatedHabit) {
    setState(() {
      habits[index] = updatedHabit;
    });

    saveHabits();
  }

  // deletes habit
  void deleteHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });

    saveHabits();
  }

  // counts finished habits
  int getCompletedCount() {
    int count = 0;
    for (int i = 0; i < habits.length; i++) {
      if (habits[i]['done'] == true) {
        count++;
      }
    }
    return count;
  }

  // builds home screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAF6FF),
        foregroundColor: const Color(0xFF0D47A1),
        title: const Text(
          'HabitFlow',
          style: TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // add habit button
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddHabitPage()),
              );

              if (result != null) {
                addHabit(result);
              }
            },
            icon: const Icon(Icons.add),
          ),

          // progress page button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProgressPage(
                    totalHabits: habits.length,
                    completedHabits: getCompletedCount(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.bar_chart),
          ),

          // about page button
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),

      // shows empty message or habit list
      body: habits.isEmpty
          ? const Center(
              child: Text(
                'No habits added yet',
                style: TextStyle(color: Color(0xFF0D47A1), fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) {
                return Card(
                  color: getCategoryColor(habits[index]['category']),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    // checkbox for done
                    leading: Checkbox(
                      value: habits[index]['done'],
                      onChanged: (value) {
                        setState(() {
                          habits[index]['done'] = value!;
                        });

                        saveHabits();
                      },
                    ),

                    // habit name
                    title: Text(
                      habits[index]['name'],
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // category and frequency
                    subtitle: Text(
                      '${habits[index]['category']} | ${habits[index]['frequency']}',
                      style: const TextStyle(color: Color(0xFF1565C0)),
                    ),

                    // arrow icon
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF0D47A1),
                    ),

                    // opens habit details
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HabitDetailsPage(
                            habit: habits[index],
                            index: index,
                          ),
                        ),
                      );

                      if (result != null) {
                        if (result['action'] == 'update') {
                          updateHabit(index, result['habit']);
                        } else if (result['action'] == 'delete') {
                          deleteHabit(index);
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}

// add habit page
class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

// add habit data
class _AddHabitPageState extends State<AddHabitPage> {
  // text boxes
  TextEditingController nameController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  // default dropdown values
  String selectedCategory = 'Health';
  String selectedFrequency = 'Daily';

  // builds add page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // habit name input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // category dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Health', child: Text('Health')),
                DropdownMenuItem(value: 'School', child: Text('School')),
                DropdownMenuItem(value: 'Fitness', child: Text('Fitness')),
                DropdownMenuItem(value: 'Personal', child: Text('Personal')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 15),

            // frequency dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedFrequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFrequency = value!;
                });
              },
            ),
            const SizedBox(height: 15),

            // notes input
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // saves new habit
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'name': nameController.text,
                    'category': selectedCategory,
                    'frequency': selectedFrequency,
                    'notes': notesController.text,
                    'done': false,
                  });
                }
              },
              child: const Text('Save Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

// habit detail page
class HabitDetailsPage extends StatefulWidget {
  final Map<String, dynamic> habit;
  final int index;

  const HabitDetailsPage({super.key, required this.habit, required this.index});

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

// detail page data
class _HabitDetailsPageState extends State<HabitDetailsPage> {
  late Map<String, dynamic> currentHabit;

  // copies selected habit
  @override
  void initState() {
    super.initState();
    currentHabit = Map<String, dynamic>.from(widget.habit);
  }

  // builds detail screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // shows habit name
            Text(
              'Habit: ${currentHabit['name']}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),

            // shows category
            Text('Category: ${currentHabit['category']}'),
            const SizedBox(height: 10),

            // shows frequency
            Text('Frequency: ${currentHabit['frequency']}'),
            const SizedBox(height: 10),

            // shows notes
            Text('Notes: ${currentHabit['notes']}'),
            const SizedBox(height: 10),

            // completed checkbox
            Row(
              children: [
                const Text('Completed: '),
                Checkbox(
                  value: currentHabit['done'],
                  onChanged: (value) {
                    setState(() {
                      currentHabit['done'] = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // saves changes
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'action': 'update',
                  'habit': currentHabit,
                });
              },
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 10),

            // deletes habit
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'action': 'delete'});
              },
              child: const Text('Delete Habit'),
            ),
          ],
        ),
      ),
    );
  }
}

// progress screen
class ProgressPage extends StatelessWidget {
  final int totalHabits;
  final int completedHabits;

  const ProgressPage({
    super.key,
    required this.totalHabits,
    required this.completedHabits,
  });

  @override
  Widget build(BuildContext context) {
    // percent number
    double progress = 0;

    // avoids dividing by zero
    if (totalHabits > 0) {
      progress = completedHabits / totalHabits;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // total habits
            Text(
              'Total Habits: $totalHabits',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),

            // completed habits
            Text(
              'Completed Habits: $completedHabits',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // progress bar
            LinearProgressIndicator(value: progress, minHeight: 10),
            const SizedBox(height: 20),

            // progress percent
            Text(
              'Progress: ${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// about page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // app name
            Text('HabitFlow', style: TextStyle(fontSize: 22)),
            SizedBox(height: 10),

            // app description
            Text(
              'HabitFlow is a mobile app that helps users track daily habits and stay organized.',
            ),
            SizedBox(height: 20),

            // project info
            Text('Hibah Malik'),
            Text('IT 315'),
            Text('Copyright © 2026'),
          ],
        ),
      ),
    );
  }
}
