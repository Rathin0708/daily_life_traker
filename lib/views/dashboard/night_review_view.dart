import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/routine_viewmodel.dart';

class NightReviewView extends StatefulWidget {
  const NightReviewView({super.key});

  @override
  State<NightReviewView> createState() => _NightReviewViewState();
}

class _NightReviewViewState extends State<NightReviewView> {
  String _selectedMood = 'Happy';
  final _reflectionController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'label': 'Happy', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
    {'label': 'Neutral', 'icon': Icons.sentiment_neutral, 'color': Colors.amber},
    {'label': 'Sad', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    final routineVM = context.watch<RoutineViewModel?>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('End of Day Review'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'How was your discipline today?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood['label']),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? mood['color'].withOpacity(0.2) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? mood['color'] : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          mood['icon'],
                          size: 40,
                          color: isSelected ? mood['color'] : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood['label'],
                        style: TextStyle(
                          color: isSelected ? mood['color'] : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            const Text(
              'Reflections & Tomorrow\'s Improvements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reflectionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'What went well? What can you improve tomorrow?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                if (routineVM != null) {
                  await routineVM.saveReflection(
                    mood: _selectedMood,
                    reflection: _reflectionController.text,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Daily Review Saved!')),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Complete Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
