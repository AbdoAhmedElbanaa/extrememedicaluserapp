import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../models/ticket_model.dart';

class TicketDetailsBottomSheet extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailsBottomSheet({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isClosed = ticket.status == 'RESOLVED' || ticket.status == 'CLOSED';
    final isInReview = ticket.status == 'IN REVIEW';

    Color stateColor;
    if (isClosed) {
      stateColor = ticket.status == 'CLOSED' ? Colors.grey : AppColors.success;
    } else {
      stateColor = isInReview ? AppColors.primary : Colors.amber;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.id,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: stateColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Text(
                  ticket.status,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.subject,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Created on ${_formatTimestamp(ticket.timestamp)}',
            style: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Container(height: 1, color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight),
          const SizedBox(height: 20),

          // Ticket Details List
          _buildDetailRow('Device Serial', ticket.serialNo, isDark),
          _buildDetailRow('Device Model', ticket.deviceName, isDark),
          if (ticket.errorCode != null) _buildDetailRow('Error Code', ticket.errorCode!, isDark),
          _buildDetailRow('Priority', ticket.priority, isDark),
          const SizedBox(height: 16),

          // Description Box
          Text(
            'Description',
            style: TextStyle(
              color: isDark ? AppColors.primary : Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1,
              ),
            ),
            child: Text(
              ticket.description,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Attachments Section
          if (ticket.attachments.isNotEmpty) ...[
            Text(
              'Attachments',
              style: TextStyle(
                color: isDark ? AppColors.primary : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ticket.attachments.length,
                itemBuilder: (context, index) {
                  final url = ticket.attachments[index];
                  final isImg = _isImageUrl(url);
                  return GestureDetector(
                    onTap: () => _openAttachment(context, url),
                    child: Container(
                      width: 70,
                      height: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                        ),
                      ),
                      child: Center(
                        child: isImg
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: CachedNetworkImage(
                                  imageUrl: url,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                _isVideoUrl(url) ? Icons.play_circle_outline_rounded : Icons.insert_drive_file_outlined,
                                color: isDark ? Colors.white54 : Colors.black54,
                                size: 24,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Resolution / Answer Note
          if (ticket.resolutionText != null || ticket.status == 'RESOLVED') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withValues(alpha: 0.25), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Resolution Note',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ticket.resolutionText ?? 'Your request has been resolved. You can now open a new support request if needed.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  if (ticket.resolvedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Resolved on ${_formatTimestamp(ticket.resolvedAt!)}',
                      style: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Got it Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.8) : Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(
                  color: isDark ? AppColors.distinctBorderDark : Colors.transparent,
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white30 : Colors.black38,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _openAttachment(BuildContext context, String url) {
    // Open full image / browser view
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: _isImageUrl(url)
                    ? CachedNetworkImage(
                        imageUrl: url,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                      )
                    : Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file_outlined, color: Colors.white, size: 48),
                            const SizedBox(height: 16),
                            const Text('Attachment File', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isImageUrl(String url) {
    if (url.startsWith('data:image/')) return true;
    final cleanUrl = url.split('?').first.split('#').first.toLowerCase();
    return cleanUrl.endsWith('.jpg') ||
        cleanUrl.endsWith('.jpeg') ||
        cleanUrl.endsWith('.png') ||
        cleanUrl.endsWith('.gif') ||
        cleanUrl.endsWith('.webp') ||
        cleanUrl.contains('picsum');
  }

  bool _isVideoUrl(String url) {
    if (url.startsWith('data:video/')) return true;
    final cleanUrl = url.split('?').first.split('#').first.toLowerCase();
    return cleanUrl.endsWith('.mp4') ||
        cleanUrl.endsWith('.mov') ||
        cleanUrl.endsWith('.avi') ||
        cleanUrl.endsWith('.mkv') ||
        cleanUrl.endsWith('.webm');
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
