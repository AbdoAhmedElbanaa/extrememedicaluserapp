import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';
import '../widgets/audio_message_bubble.dart';
import '../widgets/video_message_bubble.dart';

class ChatSupportView extends GetView<ChatController> {
  const ChatSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      body: Stack(
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
              top: -80,
              right: -80,
              width: 300,
              height: 300,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
          if (isDark)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(color: Colors.transparent),
              ),
            ),
          SafeArea(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    _buildAppBar(isDark),
                    Expanded(
                      child: _buildMessagesList(isDark),
                    ),
                    _buildBottomBar(isDark),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.ticket.subject,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.green, blurRadius: 4, spreadRadius: 1)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Extreme Medical Support Agent',
                      style: TextStyle(
                        color: isDark ? Colors.white30 : Colors.black38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.ticket.id,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isDark) {
    return Obx(() {
      final list = controller.messages;
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Send a message to start the conversation.',
                style: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black38,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final msg = list[index];
          final isMe = msg.senderId != 'admin';
          
          if (msg.isSystem) {
            return _buildSystemBubble(msg, isDark);
          }
          return _buildChatBubble(msg, isMe, isDark);
        },
      );
    });
  }

  Widget _buildChatBubble(ChatMessageModel msg, bool isMe, bool isDark) {
    final timeStr = _formatTimestamp(msg.timestamp);
    final isImage = msg.type == 'image';
    final isVideo = msg.type == 'video';
    final isAudio = msg.type == 'audio';

    Widget bubbleContent;
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

    if (isAudio) {
      bubbleContent = AudioMessageBubble(url: msg.mediaUrl!, isMe: isMe);
    } else if (isImage) {
      padding = EdgeInsets.zero;
      bubbleContent = GestureDetector(
        onTap: () {
          Get.dialog(
            Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      child: CachedNetworkImage(
                        imageUrl: msg.mediaUrl!,
                        placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white30),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
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
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetworkImage(
            imageUrl: msg.mediaUrl!,
            placeholder: (context, url) => Container(
              width: 220,
              height: 160,
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: 220,
              height: 160,
              color: Colors.black26,
              child: const Icon(Icons.image_not_supported_outlined, color: Colors.redAccent),
            ),
            fit: BoxFit.cover,
            width: 220,
            height: 160,
          ),
        ),
      );
    } else if (isVideo) {
      padding = EdgeInsets.zero;
      bubbleContent = VideoMessageBubble(url: msg.mediaUrl!, isMe: isMe);
    } else {
      bubbleContent = Text(
        msg.message,
        style: TextStyle(
          color: isMe ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          fontSize: 13.5,
          height: 1.45,
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 290),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: isMe && !isImage && !isVideo
                    ? const LinearGradient(colors: [AppColors.primary, AppColors.indigoPrimaryDark])
                    : null,
                color: isMe
                    ? (isImage || isVideo ? Colors.transparent : null)
                    : (isDark ? AppColors.cinematicSurface : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                        width: 1,
                      ),
                boxShadow: isMe && !isImage && !isVideo
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: bubbleContent,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isMe) ...[
                  Text(
                    msg.senderName,
                    style: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black26,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  timeStr,
                  style: TextStyle(
                    color: isDark ? Colors.white24 : Colors.black26,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0, duration: 250.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildSystemBubble(ChatMessageModel msg, bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Text(
          msg.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Obx(() {
      if (controller.isClosed) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? Colors.red.withValues(alpha: 0.06) : Colors.red.withValues(alpha: 0.04),
            border: Border(
              top: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2), width: 1.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, color: Colors.redAccent, size: 18),
              const SizedBox(width: 8),
              Text(
                'This support ticket has been resolved & closed.',
                style: TextStyle(
                  color: isDark ? Colors.redAccent.shade100 : Colors.redAccent.shade700,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.isRecording.value) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1.2,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 600.ms),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recording voice note...',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.cancelRecording(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => controller.stopAndSendRecording(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        );
      }

      return Builder(builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cinematicSurface.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.7),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                width: 1.2,
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showAttachmentBottomSheet(context, isDark),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                    ),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: isDark ? Colors.white70 : Colors.black54,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
                    ),
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Type response to support...',
                      hintStyle: TextStyle(color: Colors.white30, fontSize: 13.5),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(() {
                final isSending = controller.isSending.value;
                final hasText = controller.currentInputText.value.trim().isNotEmpty;

                return GestureDetector(
                  onTap: isSending
                      ? null
                      : (hasText
                          ? () => controller.sendChatMessage()
                          : () => controller.startRecording()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.indigoPrimaryDark],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Center(
                      child: isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Icon(
                              hasText ? Icons.send_rounded : Icons.mic_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      });
    });
  }

  void _showAttachmentBottomSheet(BuildContext context, bool isDark) {
    Get.bottomSheet(
      Container(
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
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Send Attachment',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Photo Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickAndSendMedia('Photo');
                  },
                  isDark: isDark,
                ),
                _buildAttachmentOption(
                  icon: Icons.video_library_rounded,
                  label: 'Video Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickAndSendMedia('Video');
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
    return '$hour:$minuteStr $ampm';
  }
}
