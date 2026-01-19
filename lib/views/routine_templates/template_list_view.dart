import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/template_viewmodel.dart';
import 'create_template_view.dart';
import '../../core/theme/app_theme.dart';

class TemplateListView extends StatelessWidget {
  const TemplateListView({super.key});

  @override
  Widget build(BuildContext context) {
    final templateVM = context.watch<TemplateViewModel?>();

    if (templateVM == null || templateVM.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final templates = templateVM.templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ROUTINE BLUEPRINTS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
        centerTitle: true,
      ),
      body: templates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.architecture, size: 80, color: Colors.white10),
                  const SizedBox(height: 24),
                  const Text('No blueprints initialized.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToCreate(context),
                    icon: const Icon(Icons.add),
                    label: const Text('INITIALIZE FIRST ROUTINE'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: templates.length,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemBuilder: (context, index) {
                final template = templates[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: template.isActive ? AppColors.primary.withValues(alpha: 0.3) : Colors.white10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      template.name.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        template.daysOfWeek.join(' • ').toUpperCase(),
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            activeColor: AppColors.primary,
                            value: template.isActive,
                            onChanged: (val) => templateVM.toggleTemplateStatus(template.id, val),
                          ),
                        ),
                        Text(
                          template.isActive ? 'ACTIVE' : 'DORMANT',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: template.isActive ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('NEW BLUEPRINT'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateTemplateView()),
    );
  }
}
