import 'package:flutter/material.dart';
import '../models/help_topic.dart';

class HelpService {
  Future<List<HelpTopic>> getHelpTopics() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      HelpTopic(
        id: '1',
        title: 'FAQs',
        description: 'Commonly asked questions and troubleshooting steps.',
        icon: Icons.question_answer_outlined,
      ),
      HelpTopic(
        id: '2',
        title: 'Contact Us',
        description: 'Reach out to our support team for personalized assistance.',
        icon: Icons.contact_support_outlined,
      ),
      HelpTopic(
        id: '3',
        title: 'User Guide',
        description: 'Comprehensive guide on how to navigate and use the application.',
        icon: Icons.menu_book_outlined,
      ),
      HelpTopic(
        id: '4',
        title: 'Video Tutorials',
        description: 'Watch step-by-step videos on setting up your devices.',
        icon: Icons.play_circle_outline,
      ),
    ];
  }
}
