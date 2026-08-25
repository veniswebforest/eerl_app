import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/help_faq_item.dart';
import '../widgets/help_faq_list.dart';
import '../widgets/help_support_assets.dart';
import '../widgets/support_contact_card.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _expandedFaqIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final faqs = [
      HelpFaqItem(
        question: l10n.helpPrinterQuestion,
        answer: l10n.helpPrinterAnswer,
      ),
      HelpFaqItem(
        question: l10n.helpAddExpenseQuestion,
        answer: l10n.helpAddExpenseAnswer,
      ),
      HelpFaqItem(
        question: l10n.helpTransferQuestion,
        answer: l10n.helpTransferAnswer,
      ),
      HelpFaqItem(question: l10n.helpSyncQuestion, answer: l10n.helpSyncAnswer),
      HelpFaqItem(
        question: l10n.helpBluetoothQuestion,
        answer: l10n.helpBluetoothAnswer,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppScreenHeader(
                      title: l10n.drawerHelpSupport,
                      leading: Material(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          key: const Key('help-support-back'),
                          onTap: widget.onBack,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              HelpSupportAssets.back,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SupportContactCard(
                      key: const Key('help-call-support'),
                      title: l10n.helpCallSupport,
                      subtitle: l10n.helpCallSupportSubtitle,
                      icon: HelpSupportAssets.call,
                      externalIcon: HelpSupportAssets.externalBlue,
                      accentColor: AppColors.secondary500,
                      iconBackgroundColor: AppColors.secondary100,
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    SupportContactCard(
                      key: const Key('help-instant-support'),
                      title: l10n.helpInstantHelp,
                      subtitle: l10n.helpInstantHelpSubtitle,
                      icon: HelpSupportAssets.whatsapp,
                      externalIcon: HelpSupportAssets.externalGreen,
                      accentColor: AppColors.primary500,
                      iconBackgroundColor: AppColors.primary50,
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.helpFrequentlyAskedQuestions,
                      style: AppTextStyles.semiboldH7_18.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 16),
                    HelpFaqList(
                      items: faqs,
                      expandedIndex: _expandedFaqIndex,
                      onItemTap: (index) => setState(() {
                        _expandedFaqIndex = _expandedFaqIndex == index
                            ? null
                            : index;
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
