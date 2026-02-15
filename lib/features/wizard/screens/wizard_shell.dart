// lib/features/wizard/screens/wizard_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_session_model.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../wizard/widgets/step_1_identity.dart';
import '../../wizard/widgets/step_2_academic.dart';
import '../../wizard/widgets/step_3_financial.dart';
import '../../wizard/widgets/step_4_talents.dart';
import '../../dashboard/screens/main_dashboard_shell.dart';

class WizardShell extends StatelessWidget {
  const WizardShell({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Consumer<UserSessionModel>(
      builder: (context, model, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: isMobile
              ? AppBar(
                  title: const Text("Setup Wizard"),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  elevation: 0,
                )
              : null,
          drawer: isMobile ? _buildSidebar(context, model) : null,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                  Colors.white,
                ],
              ),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sidebar: Hidden on mobile, persistent on desktop
                  if (!isMobile)
                    SizedBox(
                      width: 280,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GlassContainer(
                          padding: EdgeInsets.zero,
                          child: _buildSidebarContent(context, model),
                        ),
                      ),
                    ),

                  // Content Area
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: GlassContainer(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: _buildStepContent(model.currentStep),
                              ),
                            ),
                          ),
                        ),
                        // Footer navigation
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 16.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (model.currentStep > 0)
                                  ElevatedButton.icon(
                                    onPressed: () => model.previousStep(),
                                    icon: const Icon(Icons.arrow_back),
                                    label: const Text("Back"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white.withOpacity(
                                        0.5,
                                      ),
                                      foregroundColor: Colors.black87,
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),

                                if (model.currentStep < 3)
                                  ElevatedButton.icon(
                                    onPressed: () => model.nextStep(),
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text("Next"),
                                    iconAlignment: IconAlignment.end,
                                  )
                                else
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      // Save and Navigate to Dashboard
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Saving profile..."),
                                          duration: Duration(seconds: 1),
                                        ),
                                      );

                                      try {
                                        await model.saveUserProfileToFirebase();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("Profile saved!"),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const MainDashboardShell(),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text("Save failed: $e"),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 5,
                                              ),
                                              action: SnackBarAction(
                                                label: 'Retry',
                                                onPressed: () {
                                                  // Logic to retry could go here,
                                                  // but user can just click Finish again.
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.check),
                                    label: const Text("Finish Setup"),
                                    iconAlignment: IconAlignment.end,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return const Step1Identity();
      case 1:
        return const Step2Academic();
      case 2:
        return const Step3Financial();
      case 3:
        return const Step4Talents();
      default:
        return const Center(child: Text("Unknown Step"));
    }
  }

  Widget _buildSidebar(BuildContext context, UserSessionModel model) {
    return Drawer(child: _buildSidebarContent(context, model));
  }

  Widget _buildSidebarContent(BuildContext context, UserSessionModel model) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24, left: 16),
          child: Text(
            "Profile Setup",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        _SidebarItem(
          title: "Identity",
          subtitle: "Who are you?",
          index: 0,
          currentIndex: model.currentStep,
          onTap: () => model.goToStep(0),
        ),
        _SidebarItem(
          title: "Academic",
          subtitle: "Your results",
          index: 1,
          currentIndex: model.currentStep,
          onTap: () => model.goToStep(1),
        ),
        _SidebarItem(
          title: "Financial",
          subtitle: "Household info",
          index: 2,
          currentIndex: model.currentStep,
          onTap: () => model.goToStep(2),
        ),
        _SidebarItem(
          title: "Talents",
          subtitle: "Co-curricular",
          index: 3,
          currentIndex: model.currentStep,
          onTap: () => model.goToStep(3),
        ),
      ],
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.subtitle,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final isCompleted = index < currentIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        enabled:
            isCompleted ||
            isActive, // Only allow navigating strictly backwards or current
        leading: CircleAvatar(
          backgroundColor: isActive
              ? Theme.of(context).primaryColor
              : (isCompleted ? Colors.green : Colors.grey.shade200),
          foregroundColor: isActive || isCompleted
              ? Colors.white
              : Colors.grey.shade600,
          child: isCompleted
              ? const Icon(Icons.check, size: 16)
              : Text("${index + 1}"),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? Theme.of(context).primaryColor : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
