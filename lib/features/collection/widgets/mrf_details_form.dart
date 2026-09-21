import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class MrfDetailsForm extends StatefulWidget {
  const MrfDetailsForm({
    super.key,
    required this.people,
    required this.selectedLabor,
    required this.onLaborSelected,
  });

  final List<String> people;
  final String? selectedLabor;
  final ValueChanged<String> onLaborSelected;

  @override
  State<MrfDetailsForm> createState() => _MrfDetailsFormState();
}

class _MrfDetailsFormState extends State<MrfDetailsForm> {
  bool _open = false;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _showSupervisor() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.collectionContactSupervisor,
                style: AppTextStyles.semiboldH7_18,
              ),
              const SizedBox(height: 16),
              const _ContactCard(
                cardKey: Key('mrf-contact-supervisor-details'),
                fullName: 'Chunilal Yadav',
                mobileNumber: '1234567890',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _laborSelector(BuildContext context) {
    final people = widget.people
        .where(
          (person) =>
              person.toLowerCase().contains(_search.text.trim().toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: context.l10n.collectionMrfLabor, required: true),
        const SizedBox(height: 8),
        if (!_open)
          InkWell(
            key: const Key('mrf-labor-selector'),
            onTap: () => setState(() => _open = true),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.cool400),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedLabor ??
                          context.l10n.collectionSelectPerson,
                      style: AppTextStyles.regularB7_14.copyWith(
                        color: widget.selectedLabor == null
                            ? AppColors.cool400
                            : AppColors.neutral900,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/home/chevron_down.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          )
        else ...[
          TextField(
            key: const Key('mrf-labor-search'),
            controller: _search,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.regularB7_14,
            decoration: InputDecoration(
              suffixIcon: Padding(
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset(
                  'assets/icons/wallet/search.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                if (people.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(context.l10n.personNotFound),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 204),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: people.length,
                      itemBuilder: (context, index) {
                        final person = people[index];
                        final selected = widget.selectedLabor == person;
                        return InkWell(
                          key: ValueKey('mrf-labor-$person'),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            widget.onLaborSelected(person);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary500
                                          : AppColors.cool400,
                                    ),
                                  ),
                                  child: selected
                                      ? const DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary500,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    person,
                                    style: AppTextStyles.regularB7_14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    key: const Key('mrf-contact-supervisor'),
                    onPressed: _showSupervisor,
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(),
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/help_support/call.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(
                      context.l10n.collectionContactSupervisorIfNotFound,
                      style: AppTextStyles.regularB8_12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(text: context.l10n.collectionTypes, required: true),
      const SizedBox(height: 8),
      Container(
        key: const Key('mrf-fixed-collection-type'),
        width: double.infinity,
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.cool200,
          border: Border.all(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/home/collection_mrf.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.neutral900,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.collectionMrfShort,
              style: AppTextStyles.regularB7_14,
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        context.l10n.collectionMrfDetails,
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 8),
      const _ContactCard(
        cardKey: Key('mrf-supervisor-details'),
        fullName: 'Chunilal Yadav',
        mobileNumber: '1234567890',
      ),
      const SizedBox(height: 8),
      Text.rich(
        key: const Key('mrf-team-verification'),
        TextSpan(
          text: context.l10n.collectionTeamVerifiedBy,
          children: [
            TextSpan(
              text: context.l10n.collectionSupervisor,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.primary500,
              ),
            ),
          ],
        ),
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.cool600),
      ),
      const SizedBox(height: 24),
      _laborSelector(context),
    ],
  );
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.cardKey,
    required this.fullName,
    required this.mobileNumber,
  });

  final Key cardKey;
  final String fullName;
  final String mobileNumber;

  @override
  Widget build(BuildContext context) => Container(
    key: cardKey,
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.cool200,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailLine(label: context.l10n.collectionFullName, value: fullName),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: AppColors.cool400),
        ),
        _DetailLine(
          label: context.l10n.collectionMobileNumber,
          value: mobileNumber,
        ),
      ],
    ),
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral700),
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.neutral900,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH9_14,
            ),
          ),
        ],
      ),
    ],
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: text,
      children: required
          ? const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.red600),
              ),
            ]
          : const [],
    ),
    style: AppTextStyles.mediumSH8_14,
  );
}
