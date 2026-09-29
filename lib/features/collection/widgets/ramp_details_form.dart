import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'add_new_ragpicker_bottom_sheet.dart';

/// Ramp-specific fields from the first collection step.
class RampDetailsForm extends StatefulWidget {
  const RampDetailsForm({
    super.key,
    required this.personNames,
    required this.selectedPerson,
    required this.photo,
    required this.onPersonSelected,
    required this.onAddNewPerson,
    required this.onCapturePhoto,
    required this.onRemovePhoto,
    required this.onPreviewPhoto,
  });

  final List<String> personNames;
  final String? selectedPerson;
  final XFile? photo;
  final ValueChanged<String?> onPersonSelected;
  final ValueChanged<String> onAddNewPerson;
  final VoidCallback onCapturePhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onPreviewPhoto;

  @override
  State<RampDetailsForm> createState() => _RampDetailsFormState();
}

class _RampDetailsFormState extends State<RampDetailsForm> {
  bool _isPersonDropdownOpen = false;
  final TextEditingController _personSearchController = TextEditingController();

  @override
  void dispose() {
    _personSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _personSearchController.text.trim().toLowerCase();
    final filteredPeople = widget.personNames
        .where((person) => person.toLowerCase().contains(query))
        .toList();
    final noResults =
        _isPersonDropdownOpen && query.isNotEmpty && filteredPeople.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel(context.l10n.collectionRagpickerPerson),
        const SizedBox(height: 8),
        if (_isPersonDropdownOpen)
          _buildSearchField(noResults: noResults)
        else
          _buildClosedSelector(),
        if (_isPersonDropdownOpen) ...[
          const SizedBox(height: 6),
          if (noResults)
            _buildPersonNotFound(context)
          else
            _buildPersonList(filteredPeople),
        ],
        const SizedBox(height: 20),
        _buildPhotoCard(context),
      ],
    );
  }

  Widget _requiredLabel(String label) => Text.rich(
    TextSpan(
      text: label.endsWith(' *') ? label.substring(0, label.length - 2) : label,
      children: const [
        TextSpan(
          text: ' *',
          style: TextStyle(color: AppColors.red500),
        ),
      ],
    ),
    style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral900),
  );

  Widget _buildClosedSelector() {
    final placeholder = widget.selectedPerson == null;
    return InkWell(
      key: const Key('ramp-person-selector'),
      onTap: () => setState(() {
        _isPersonDropdownOpen = true;
        _personSearchController.clear();
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cool400),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.selectedPerson ?? context.l10n.collectionSelectPerson,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: placeholder ? AppColors.cool400 : AppColors.neutral950,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.neutral900),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField({required bool noResults}) => Container(
    key: const Key('ramp-person-search'),
    height: 55,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: noResults ? AppColors.red400 : AppColors.cool400,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _personSearchController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.regularB7_14.copyWith(
              color: noResults ? AppColors.red500 : AppColors.neutral950,
            ),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              hintText: context.l10n.recordsSearchHint,
              hintStyle: AppTextStyles.regularB7_14.copyWith(
                color: AppColors.cool400,
              ),
            ),
          ),
        ),
        SvgPicture.asset(
          'assets/icons/wallet/search.svg',
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            AppColors.neutral900,
            BlendMode.srcIn,
          ),
        ),
      ],
    ),
  );

  Widget _buildPersonList(List<String> people) => Container(
    constraints: const BoxConstraints(maxHeight: 224),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.cool400),
    ),
    child: ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: people.length,
      separatorBuilder: (_, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final person = people[index];
        return InkWell(
          onTap: () {
            widget.onPersonSelected(person);
            setState(() {
              _personSearchController.clear();
            });
          },
          child: Container(
            color: widget.selectedPerson == person
                ? AppColors.red100
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _radio(widget.selectedPerson == person),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    person,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                PopupMenuButton<void>(
                  key: Key('ramp-edit-person-$index'),
                  padding: EdgeInsets.zero,

                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  constraints: const BoxConstraints(),
                  menuPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.cool400),
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                  ),
                  position: PopupMenuPosition.over,
                  itemBuilder: (context) => [
                    PopupMenuItem<void>(
                      height: 44,
                      child: Text(
                        context.l10n.deactivate,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.red600,
                        ),
                      ),
                    ),
                  ],
                  child: SvgPicture.asset(
                    'assets/icons/collection/edit_person.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _buildPersonNotFound(BuildContext context) => Container(
    key: const Key('ramp-person-not-found'),
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.cool400),
    ),
    child: Column(
      children: [
        Text(
          context.l10n.personNotFound,
          textAlign: TextAlign.center,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.contactAdminToAssignStaff,
          textAlign: TextAlign.center,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            key: const Key('ramp-add-person'),
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() => _isPersonDropdownOpen = false);
              AddNewRagpickerBottomSheet.show(
                context,
                onSave: widget.onAddNewPerson,
              );
            },
            icon: const Icon(Icons.add_box_outlined, size: 20),
            label: Text(context.l10n.add.replaceFirst('+ ', '')),
          ),
        ),
      ],
    ),
  );

  Widget _radio(bool selected) => Container(
    width: 16,
    height: 16,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.cool400,
        width: selected ? 4.5 : 1.2,
      ),
    ),
  );

  Widget _buildPhotoCard(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.cool200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _requiredLabel(context.l10n.captureVehiclePhoto),
        const SizedBox(height: 8),
        _buildPhotoContent(context),
        const SizedBox(height: 12),
        Text(
          context.l10n.collectionVehiclePhotoHint,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    ),
  );

  Widget _buildPhotoContent(BuildContext context) {
    if (widget.photo != null) {
      return SizedBox(
        width: 109,
        height: 70,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(widget.photo!.path), fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    _photoAction(Icons.fullscreen, widget.onPreviewPhoto),
                    const SizedBox(width: 6),
                    _photoAction(Icons.close, widget.onRemovePhoto),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DottedBorder(
      options: const RoundedRectDottedBorderOptions(
        radius: Radius.circular(10),
        color: AppColors.primary500,
        dashPattern: [5, 4],
        strokeWidth: 1,
      ),
      child: InkWell(
        key: const Key('ramp-capture-vehicle-photo'),
        onTap: widget.onCapturePhoto,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          height: 82,
          color: const Color(0xFFF2FCF4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/collection/capture_camera.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.collectionCapturePhoto,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoAction(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}
