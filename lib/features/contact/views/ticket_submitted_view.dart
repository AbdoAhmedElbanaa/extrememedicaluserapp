import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import '../models/ticket_model.dart';
import '../controllers/contact_controller.dart';

class TicketSubmittedView extends StatelessWidget {
  const TicketSubmittedView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Retrieve ticket from arguments or create fallback
    final TicketModel ticket = Get.arguments as TicketModel? ?? TicketModel(
      id: 'UM-17039',
      subject: 'Device Not Working',
      priority: 'Medium',
      description: 'Test description',
      status: 'IN REVIEW',
      userId: 'test',
      clinicName: 'Test Clinic',
      deviceName: 'SmartThermo Pro',
      serialNo: 'SN-2024-001234',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      attachments: const [],
    );

    final controller = Get.find<ContactController>();
    final estResponse = controller.config.value?.responseTime ?? '2-4 business hours';

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Giant green check mark
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 2.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Heading
                  Text(
                    'Ticket Submitted!',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    'Our support team has received your request.\nWe\'ll reply as soon as possible.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Ticket Details Card
                  _buildDetailsCard(ticket, estResponse, isDark),
                  const SizedBox(height: 40),

                  // Big Track Button
                  _buildTrackButton(ticket, context),
                  const SizedBox(height: 16),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildSecondaryButton(
                          icon: Icons.history_rounded,
                          label: 'My Tickets',
                          onTap: () {
                            Get.offNamed(AppRoutes.mySupportRequests);
                          },
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSecondaryButton(
                          icon: Icons.help_outline_rounded,
                          label: 'Help Center',
                          onTap: () => Get.offAllNamed(AppRoutes.home),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(TicketModel ticket, String estResponse, bool isDark) {
    // Priority styling
    Color priorityColor;
    switch (ticket.priority.toLowerCase()) {
      case 'low':
        priorityColor = Colors.blue;
        break;
      case 'medium':
        priorityColor = const Color(0xFFFF9F1C);
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      case 'critical':
        priorityColor = Colors.red;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Ticket ID Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.confirmation_number_outlined, color: isDark ? Colors.white30 : Colors.black38, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Ticket ID',
                          style: TextStyle(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        ticket.id,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDivider(isDark),
                const SizedBox(height: 20),

                // Subject Row
                _buildDetailRow(Icons.chat_bubble_outline_rounded, 'Subject', ticket.subject, isDark),
                const SizedBox(height: 18),

                // Est Response Row
                _buildDetailRow(Icons.timer_outlined, 'Est. Response', estResponse, isDark, valueColor: Colors.green),
                const SizedBox(height: 18),

                // Device Row
                _buildDetailRow(Icons.memory_rounded, 'Device', ticket.serialNo, isDark),
                const SizedBox(height: 18),

                // Priority Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: isDark ? Colors.white30 : Colors.black38, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Priority',
                          style: TextStyle(
                            color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ticket.priority,
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Banner at bottom of card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9F1C).withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
              border: Border(
                top: BorderSide(
                  color: const Color(0xFFFF9F1C).withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9F1C),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  ticket.status.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFF9F1C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Updated just now',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: isDark ? Colors.white30 : Colors.black38, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isDark ? Colors.white : Colors.black87),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildTrackButton(TicketModel ticket, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.indigoPrimaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Get.offNamed(AppRoutes.ticketTracker, arguments: ticket);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Track My Ticket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required IconData icon, required String label, required VoidCallback onTap, required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cinematicSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.white70 : Colors.black54, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
