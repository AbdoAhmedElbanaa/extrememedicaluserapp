import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class SubscriptionBillingSettingsSection extends StatelessWidget {
  const SubscriptionBillingSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SettingsExpandableTile(
      icon: Icons.credit_card_rounded,
      iconColor: AppColors.emeraldSoft,
      title: 'Subscription & Billing',
      canExpand: isMobile,
      initiallyExpanded: !isMobile,
      showHeader: isMobile,
      children: [
        SettingsSubTile(
          icon: Icons.credit_card_rounded,
          iconColor: AppColors.emeraldSoft,
          title: 'Current Plan',
          subtitle: 'Premium • 49 ر.س/month',
          trailing: _buildBadge('Active', AppColors.success, isDark),
          onTap: () {},
        ),
        SettingsSubTile(
          icon: Icons.payment_rounded,
          iconColor: AppColors.blueSoft,
          title: 'Payment Methods',
          subtitle: 'Visa ending in 4242',
          onTap: () {},
        ),
        SettingsSubTile(
          icon: Icons.receipt_long_rounded,
          iconColor: AppColors.purpleSoft,
          title: 'Billing History',
          subtitle: 'View past invoices',
          showDivider: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
