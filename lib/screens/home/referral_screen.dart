import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import 'dart:math';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final teamMembers = List.generate(10, (index) {
      final isActive = index % 2 == 0; // Alternating active/pending
      return TeamMember(
        name: "Member ${index + 1}",
        isActive: isActive,
        avatarColor: Colors.primaries[index % Colors.primaries.length],
      );
    });

    final totalTeam = teamMembers.length;
    final totalActive = teamMembers.where((m) => m.isActive).length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "MY TEAM",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.premiumDarkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Summary
              Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.glassGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(context, "$totalTeam", "Total Members", AppTheme.vividGold),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildSummaryItem(context, "$totalActive", "Active Earners", AppTheme.successGreen),
                    ],
                  ),
                ).animate().scale(curve: Curves.easeOutBack),
              ),
              
              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: teamMembers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final member = teamMembers[index];
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: member.avatarColor.withOpacity(0.5), width: 2),
                              boxShadow: [BoxShadow(color: member.avatarColor.withOpacity(0.3), blurRadius: 10)],
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: member.avatarColor.withOpacity(0.2),
                              child: Text(
                                member.name[0], 
                                style: TextStyle(fontWeight: FontWeight.bold, color: member.avatarColor)
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Joined recently",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white38),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: member.isActive ? AppTheme.successGreen.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: member.isActive ? AppTheme.successGreen.withOpacity(0.5) : Colors.white10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: member.isActive ? AppTheme.successGreen : Colors.grey,
                                    boxShadow: member.isActive ? [BoxShadow(color: AppTheme.successGreen.withOpacity(0.5), blurRadius: 6)] : [],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  member.isActive ? "Active" : "Pending",
                                  style: TextStyle(
                                    color: member.isActive ? AppTheme.successGreen : Colors.white54,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: index * 100)).slideX(begin: 0.1, end: 0);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value, 
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color, 
            fontWeight: FontWeight.bold
          )
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          )
        ),
      ],
    );
  }
}

class TeamMember {
  final String name;
  final bool isActive;
  final Color avatarColor;

  TeamMember({required this.name, required this.isActive, required this.avatarColor});
}
