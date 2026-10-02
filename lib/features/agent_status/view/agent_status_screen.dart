import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/agent_status/widgets/agent_status_card.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/app_square_back_button.dart';

class AgentStatusScreen extends StatefulWidget {
  const AgentStatusScreen({super.key});
  @override
  State<AgentStatusScreen> createState() => _AgentStatusScreenState();
}

class _AgentStatusScreenState extends State<AgentStatusScreen> {
  late final LocalQueryController<List<AgentStatusModel>> _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      EerlLocalRepository.instance.getAgentStatus,
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('agent-status-screen'),
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              final agents = _controller.data ?? const <AgentStatusModel>[];
              return ListView.separated(
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
                            style: AppTextStyles.semiboldH6_20,
                          ),
                        ),
                      ],
                    );
                  }
                  final agent = agents[index - 1];
                  return AgentStatusCard(
                    key: ValueKey(agent.userId),
                    item: agent,
                    activeLabel: context.l10n.ragpickerActive,
                    offlineLabel: context.l10n.agentStatusOffline,
                  );
                },
              );
            },
          ),
        ),
      ),
    ),
  );
}
