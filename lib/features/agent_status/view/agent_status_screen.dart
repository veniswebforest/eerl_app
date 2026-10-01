import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/agent_status/model/agent_status_item.dart';
import 'package:eerl_app/features/agent_status/widgets/agent_status_card.dart';
import 'package:eerl_app/shared/widgets/app_square_back_button.dart';

class AgentStatusScreen extends StatelessWidget {
  const AgentStatusScreen({super.key});

  static const _rahulAvatar = 'assets/images/agent_status/rahul_patel.png';
  static const _amitAvatar = 'assets/images/agent_status/amit_shah.png';
  static const _nareshAvatar = 'assets/images/agent_status/naresh_modi.png';

  @override
  Widget build(BuildContext context) {
    final agents = <AgentStatusItem>[
      AgentStatusItem(
        name: context.l10n.verificationRahulPatel,
        center: context.l10n.ragpickerCenterSurat,
        avatarAsset: _rahulAvatar,
        isActive: true,
      ),
      AgentStatusItem(
        name: context.l10n.verificationAmitShah,
        center: context.l10n.ragpickerCenterSuratWest,
        avatarAsset: _amitAvatar,
        isActive: false,
      ),
      AgentStatusItem(
        name: context.l10n.verificationNareshModi,
        center: context.l10n.ragpickerCenterSuratSouth,
        avatarAsset: _nareshAvatar,
        isActive: true,
      ),
    ];

    return Scaffold(
      key: const Key('agent-status-screen'),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              itemCount: agents.length + 1,
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == 0 ? 24 : 16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Row(
                    children: [
                      AppSquareBackButton(
                        key: const Key('agent-status-back'),
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          context.l10n.drawerSupervisorAgentStatus,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.semiboldH6_20.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final agent = agents[index - 1];
                return AgentStatusCard(
                  key: ValueKey('agent-status-${index - 1}'),
                  item: agent,
                  activeLabel: context.l10n.ragpickerActive,
                  offlineLabel: context.l10n.agentStatusOffline,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
