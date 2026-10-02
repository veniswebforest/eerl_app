import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import '../widgets/role_switcher_assets.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';

class RoleSwitcherScreen extends StatefulWidget {
  const RoleSwitcherScreen({super.key, required this.initialRole});

  final DashboardUserRole initialRole;

  @override
  State<RoleSwitcherScreen> createState() => _RoleSwitcherScreenState();
}

class _RoleSwitcherScreenState extends State<RoleSwitcherScreen> {
  late DashboardUserRole _selectedRole = widget.initialRole;
  late final LocalQueryController<
    ({List<MyRoleModel> roles, List<CenterModel> centers})
  >
  _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() async {
      final values = await Future.wait([
        EerlLocalRepository.instance.getRoles(),
        EerlLocalRepository.instance.getCenters(),
      ]);
      return (
        roles: values[0] as List<MyRoleModel>,
        centers: values[1] as List<CenterModel>,
      );
    })..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  DashboardUserRole _role(String key) => switch (key.toUpperCase()) {
    'SUPERVISOR' => DashboardUserRole.supervisor,
    'ADMIN' => DashboardUserRole.admin,
    'COLLECTION_MANAGER' => DashboardUserRole.collectionManager,
    'IEC_AGENT' => DashboardUserRole.iecAgent,
    _ => DashboardUserRole.collectionAgent,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    key: const Key('role-switcher-back'),
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset(
                        RoleSwitcherAssets.back,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    context.l10n.roleSelectTitle,
                    style: AppTextStyles.semiboldH6_20.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final data = _controller.data;
                    final roles = data?.roles ?? const <MyRoleModel>[];
                    final centerNames =
                        data?.centers.map((center) => center.name).join(', ') ??
                        '';
                    return ListView.separated(
                      itemCount: roles.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final role = _role(roles[index].roleKey);
                        return _RoleOptionCard(
                          key: ValueKey(roles[index].roleKey),
                          title: roles[index].roleName,
                          zone: centerNames,
                          icon: role == DashboardUserRole.supervisor
                              ? RoleSwitcherAssets.supervisor
                              : RoleSwitcherAssets.agent,
                          selected: _selectedRole == role,
                          onTap: () => setState(() => _selectedRole = role),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  key: const Key('role-switcher-submit'),
                  onPressed: () => Navigator.of(context).pop(_selectedRole),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.roleSwitchAction,
                        style: AppTextStyles.boldH7_16.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        RoleSwitcherAssets.arrowRight,
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    super.key,
    required this.title,
    required this.zone,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String zone;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary50 : AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? AppColors.primary500 : AppColors.cool400,
        ),
      ),
      elevation: selected ? 0 : 2,
      shadowColor: const Color(0x1F000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary200
                                : AppColors.cool200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SvgPicture.asset(
                            icon,
                            colorFilter: ColorFilter.mode(
                              selected
                                  ? AppColors.primary800
                                  : AppColors.cool500,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.semiboldH7_18.copyWith(
                              color: AppColors.neutral950,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SvgPicture.asset(
                          RoleSwitcherAssets.location,
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            zone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary500 : null,
                      shape: BoxShape.circle,
                      border: selected
                          ? null
                          : Border.all(color: AppColors.cool400, width: 1.5),
                    ),
                    child: selected
                        ? SvgPicture.asset(
                            RoleSwitcherAssets.check,
                            width: 16,
                            height: 16,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
