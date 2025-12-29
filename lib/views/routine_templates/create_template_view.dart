import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/routine_models.dart';
import '../../viewmodels/template_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class CreateTemplateView extends StatefulWidget {
  const CreateTemplateView({super.key});

  @override
  State<CreateTemplateView> createState() => _CreateTemplateViewState();
}

class _CreateTemplateViewState extends State<CreateTemplateView> {
  final _nameController = TextEditingController();
  final List<TaskTemplate> _tasks = [];
  final List<String> _selectedDays = [];

  final List<String> _allDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  void _addTask() {
    HabitType selectedType = HabitType.checkbox;
    String selectedIcon = 'check_circle';
    
    showDialog(
      context: context,
      builder: (context) {
        final taskNameController = TextEditingController();
        final taskTimeController = TextEditingController(text: '08:00');
        final durationController = TextEditingController(text: '30');
        final targetValueController = TextEditingController(text: '1.0');
        final unitController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Habit/Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: taskNameController,
                      decoration: const InputDecoration(labelText: 'Name (e.g., Water)'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<HabitType>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: HabitType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedType = val);
                      },
                    ),
                    if (selectedType == HabitType.counter) ...[
                      TextField(
                        controller: targetValueController,
                        decoration: const InputDecoration(labelText: 'Target Value'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: 'Unit (e.g., ml, glasses)'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedIcon,
                      decoration: const InputDecoration(labelText: 'Icon'),
                      items: ['check_circle', 'water', 'fitness', 'meditation', 'reading', 'coding'].map((icon) => DropdownMenuItem(
                        value: icon,
                        child: Row(
                          children: [
                            Icon(_getIconData(icon), size: 18),
                            const SizedBox(width: 8),
                            Text(icon),
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedIcon = val);
                      },
                    ),
                    TextField(
                      controller: taskTimeController,
                      decoration: const InputDecoration(labelText: 'Start Time (HH:mm)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (taskNameController.text.isNotEmpty) {
                      setState(() {
                        _tasks.add(TaskTemplate(
                          id: const Uuid().v4(),
                          name: taskNameController.text,
                          startTime: taskTimeController.text,
                          durationMinutes: int.tryParse(durationController.text) ?? 30,
                          type: selectedType,
                          icon: selectedIcon,
                          targetValue: double.tryParse(targetValueController.text) ?? 1.0,
                          unit: unitController.text,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'water': return Icons.water_drop;
      case 'fitness': return Icons.fitness_center;
      case 'meditation': return Icons.self_improvement;
      case 'reading': return Icons.menu_book;
      case 'coding': return Icons.code;
      default: return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Routine Template'),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nameController.text.isNotEmpty && _selectedDays.isNotEmpty) {
                final authVM = context.read<AuthViewModel>();
                final templateVM = context.read<TemplateViewModel?>();

                if (templateVM != null && authVM.currentUser != null) {
                  await templateVM.addTemplate(RoutineTemplate(
                    id: const Uuid().v4(),
                    userId: authVM.currentUser!.uid,
                    name: _nameController.text,
                    daysOfWeek: _selectedDays,
                    tasks: _tasks,
                  ));
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              }
            },
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name (e.g., Weekday Routine)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            const Text('SELECT DAYS', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _allDays.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(day),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TASKS', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text('${task.startTime} • ${task.durationMinutes} min'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _tasks.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
