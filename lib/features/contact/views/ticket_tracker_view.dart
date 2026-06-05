import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import '../controllers/contact_controller.dart';
import '../models/ticket_model.dart';

class _TimelineStep {
  final String title;
  final String description;
  final String? time;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  const _TimelineStep({
    required this.title,
    required this.description,
    this.time,
    required this.icon,
    this.isCompleted = false,
    this.isActive = false,
  });
}

class TicketTrackerView extends GetView<ContactController> {
  const TicketTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Retrieve ticket from arguments
    final TicketModel? argTicket = Get.arguments as TicketModel?;
    final String ticketId = argTicket?.id ?? 'UM-48291';

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      body: Obx(() {
        // Look up ticket dynamically from the active controller stream
        final ticket = controller.userTickets.firstWhere(
          (t) => t.id == ticketId,
          orElse: () => argTicket ?? TicketModel(
            id: ticketId,
            subject: 'SmartThermo Pro — Error E102',
            priority: 'High',
            description: 'Test description',
            status: 'IN REVIEW',
            userId: 'test',
            clinicName: 'Test Clinic',
            deviceName: 'SmartThermo Pro',
            serialNo: 'SN-2024-001234',
            timestamp: DateTime.now().millisecondsSinceEpoch - 7200000,
            attachments: const [],
            errorCode: 'E102',
          ),
        );

        return Stack(
          children: [
            // Background Base Color
            Positioned.fill(
              child: Container(
                color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              ),
            ),
            // Glow effect top-right (only in dark mode for premium look)
            if (isDark)
              Positioned(
                top: -100,
                right: -100,
                width: 350,
                height: 350,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
            // Glow effect bottom-left
            if (isDark)
              Positioned(
                bottom: -100,
                left: -100,
                width: 300,
                height: 300,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withValues(alpha: 0.08),
                  ),
                ),
              ),
            // Backdrop Blur overlay
            if (isDark)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            // Main content
            SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Custom Header
                      _buildHeader(ticket, isDark),
                      const SizedBox(height: 24),

                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ticket Overview Card
                              _buildOverviewCard(ticket, isDark),
                              const SizedBox(height: 32),

                              // Progress Timeline Header
                              Text(
                                'PROGRESS TIMELINE',
                                style: TextStyle(
                                  color: isDark ? Colors.white30 : Colors.black38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Dynamic Timeline list
                              _buildTimeline(ticket, isDark),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(TicketModel ticket, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cinematicSurface : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Tracker',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.id,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // History Button (Uniform style matching the back button)
        GestureDetector(
          onTap: () => Get.offNamed(AppRoutes.mySupportRequests),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cinematicSurface : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 6),
                Text(
                  'History',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(TicketModel ticket, bool isDark) {
    final isClosed = ticket.status == 'RESOLVED' || ticket.status == 'CLOSED';
    final isInReview = ticket.status == 'IN REVIEW';

    Color stateColor;
    if (isClosed) {
      stateColor = ticket.status == 'CLOSED' ? Colors.grey : AppColors.success;
    } else {
      stateColor = isInReview ? AppColors.primary : Colors.amber;
    }

    final String timeStr = _formatDateTime(ticket.timestamp);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.8) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: Support Request Date & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Support Request  •  $timeStr',
                  style: TextStyle(
                    color: isDark ? Colors.white30 : Colors.black38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stateColor.withValues(alpha: 0.2), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: stateColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ticket.status,
                      style: TextStyle(
                        color: stateColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ticket main subject
          Text(
            '${ticket.deviceName} — ${ticket.subject}',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Tags Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCardTag(ticket.id, AppColors.primary, isDark),
              if (ticket.errorCode != null) ...[
                _buildCardTag('Error: ${ticket.errorCode}', Colors.redAccent, isDark),
              ],
              _buildCardTag('2-4 business hours', Colors.grey, isDark),
            ],
          ),
          if (ticket.isChat) ...[
            const SizedBox(height: 20),
            _buildChatButton(ticket, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildCardTag(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimeline(TicketModel ticket, bool isDark) {
    final status = ticket.status;
    final isClosed = status == 'RESOLVED' || status == 'CLOSED';
    final createdTime = _formatDateTime(ticket.timestamp);

    // Calculate timestamps
    final assignedTime = _formatDateTime(ticket.timestamp + 900000); // +15 mins
    final reviewTime = _formatDateTime(ticket.timestamp + 1800000); // +30 mins
    final resolvedTime = ticket.resolvedAt != null 
        ? _formatDateTime(ticket.resolvedAt!) 
        : _formatDateTime(ticket.timestamp + 7200000); // +2 hours

    // If ticket is open (in review) and older than 15 minutes, we show 'Under Review' as active.
    // If it's open and newer than 15 minutes, we show 'Assigned to Agent' as active.
    final bool isVeryNew = DateTime.now().millisecondsSinceEpoch - ticket.timestamp < 900000;

    final List<_TimelineStep> steps = [
      _TimelineStep(
        title: 'Ticket Created',
        description: 'Your support request has been received.',
        time: createdTime,
        icon: Icons.local_activity_outlined,
        isCompleted: true,
      ),
      _TimelineStep(
        title: 'Assigned to Agent',
        description: (status == 'IN REVIEW' && isVeryNew)
            ? 'Assigning a desk agent to your case...'
            : 'Sarah K. has been assigned to your case.',
        time: (status == 'IN REVIEW' && isVeryNew) ? null : assignedTime,
        icon: Icons.person_outline_rounded,
        isCompleted: status != 'IN REVIEW' || !isVeryNew,
        isActive: status == 'IN REVIEW' && isVeryNew,
      ),
      _TimelineStep(
        title: 'Under Review',
        description: 'Agent is analyzing your reported issue.',
        time: (status == 'RESPONSE SENT' || status == 'AWAITING REPLY' || isClosed)
            ? reviewTime
            : (status == 'IN REVIEW' && !isVeryNew
                ? _formatDateTime(DateTime.now().millisecondsSinceEpoch)
                : null),
        icon: Icons.visibility_outlined,
        isCompleted: status == 'RESPONSE SENT' || status == 'AWAITING REPLY' || isClosed,
        isActive: status == 'IN REVIEW' && !isVeryNew,
      ),
      _TimelineStep(
        title: 'Response Sent',
        description: (status == 'AWAITING REPLY' || isClosed || status == 'RESPONSE SENT')
            ? (ticket.resolutionText ?? 'Agent has resolved your support ticket.')
            : 'Agent has replied to your ticket.',
        time: (status == 'AWAITING REPLY' || isClosed || status == 'RESPONSE SENT')
            ? (ticket.resolvedAt != null ? _formatDateTime(ticket.resolvedAt!) : resolvedTime)
            : null,
        icon: Icons.chat_bubble_outline_rounded,
        isCompleted: status == 'AWAITING REPLY' || isClosed,
        isActive: status == 'RESPONSE SENT',
      ),
      _TimelineStep(
        title: 'Awaiting Your Reply',
        description: 'Waiting for your response to proceed.',
        time: status == 'AWAITING REPLY' ? _formatDateTime(DateTime.now().millisecondsSinceEpoch) : null,
        icon: Icons.access_time_rounded,
        isCompleted: isClosed,
        isActive: status == 'AWAITING REPLY',
      ),
      _TimelineStep(
        title: 'Issue Resolved',
        description: 'The reported issue has been resolved.',
        time: isClosed ? (ticket.resolvedAt != null ? _formatDateTime(ticket.resolvedAt!) : resolvedTime) : null,
        icon: Icons.check_circle_outline_rounded,
        isCompleted: isClosed,
        isActive: false,
      ),
      _TimelineStep(
        title: 'Ticket Closed',
        description: 'This support request has been closed.',
        time: isClosed ? (ticket.resolvedAt != null ? _formatDateTime(ticket.resolvedAt!) : resolvedTime) : null,
        icon: Icons.close_rounded,
        isCompleted: isClosed,
        isActive: false,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final isLast = index == steps.length - 1;
          final nextStep = isLast ? null : steps[index + 1];
          
          // Connect line color
          final bool connectLine = step.isCompleted && nextStep != null && (nextStep.isCompleted || nextStep.isActive);
          
          return _buildTimelineStep(
            step: step,
            isLast: isLast,
            connectLine: connectLine,
            isDark: isDark,
          );
        }),
      ),
    );
  }

  Widget _buildTimelineStep({
    required _TimelineStep step,
    required bool isLast,
    required bool connectLine,
    required bool isDark,
  }) {
    Color iconColor;
    Color iconBg;
    Color borderStrokeColor;
    Color lineColor;
    TextStyle titleStyle;
    TextStyle descStyle;
    List<BoxShadow>? glowShadow;

    if (step.isCompleted) {
      iconColor = AppColors.success;
      iconBg = AppColors.success.withValues(alpha: 0.1);
      borderStrokeColor = AppColors.success.withValues(alpha: 0.3);
      lineColor = AppColors.success;
      titleStyle = TextStyle(
        color: isDark ? Colors.white : Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      descStyle = TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontSize: 12,
        height: 1.4,
      );
    } else if (step.isActive) {
      iconColor = AppColors.primary;
      iconBg = AppColors.primary.withValues(alpha: 0.15);
      borderStrokeColor = AppColors.primary;
      lineColor = isDark ? Colors.white12 : Colors.black12;
      titleStyle = TextStyle(
        color: isDark ? Colors.white : AppColors.foregroundLight,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      );
      descStyle = TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontSize: 12,
        height: 1.4,
      );
      if (isDark) {
        glowShadow = [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ];
      }
    } else {
      iconColor = isDark ? Colors.white24 : Colors.black26;
      iconBg = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03);
      borderStrokeColor = isDark ? Colors.white10 : Colors.black12;
      lineColor = isDark ? Colors.white10 : Colors.black12;
      titleStyle = TextStyle(
        color: isDark ? Colors.white30 : Colors.black38,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      );
      descStyle = TextStyle(
        color: isDark ? Colors.white12 : Colors.black26,
        fontSize: 12,
        height: 1.4,
      );
    }

    // Override lineColor if connectLine is true
    if (connectLine) {
      lineColor = AppColors.success;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Circle and Line
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderStrokeColor,
                  width: step.isActive ? 2 : 1,
                ),
                boxShadow: glowShadow,
              ),
              child: Icon(step.icon, color: iconColor, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 52,
                color: lineColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Right side: Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      step.title,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (step.isCompleted)
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 18,
                    )
                  else if (step.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                step.description,
                style: descStyle,
              ),
              if (step.time != null) ...[
                const SizedBox(height: 6),
                Text(
                  step.time!,
                  style: TextStyle(
                    color: step.isCompleted
                        ? (isDark ? Colors.white30 : Colors.black38)
                        : (isDark ? Colors.white12 : Colors.black26),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatButton(TicketModel ticket, bool isDark) {
    final isClosed = ticket.status == 'RESOLVED' || ticket.status == 'CLOSED';
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isClosed 
                ? [Colors.grey.shade700, Colors.grey.shade800]
                : [AppColors.primary, AppColors.indigoPrimaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isClosed ? null : [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Get.toNamed(AppRoutes.chatSupport, arguments: ticket);
          },
          icon: Icon(
            isClosed ? Icons.chat_bubble_outline_rounded : Icons.chat_bubble_rounded,
            color: Colors.white,
            size: 18,
          ),
          label: Text(
            isClosed ? 'View Chat History' : 'Enter Support Live Chat',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}, $hour:$minuteStr $ampm';
  }
}
