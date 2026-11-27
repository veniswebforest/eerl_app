import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';
import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// The app's language selector: a small box with the current language that
/// opens a list to pick English, Gujarati or Hindi.
///
/// One widget for every screen that offers a language choice (the profile
/// of every role, including the Driver and Pickup Supervisor module). It
/// changes and saves the language through [LocaleProvider]; every screen
/// follows the new locale.
///
/// The list is pinned to the box: its top-left corner sits right under the
/// box's bottom-left, at the box's width, wherever the box is on screen.
///
/// [provider] defaults to the app's [LocaleProvider] from the widget tree.
/// Without one (a module preview or widget test) the box shows English and
/// does nothing when tapped.
class AppLanguageSelector extends StatefulWidget {
  const AppLanguageSelector({super.key, this.provider});

  final LocaleProvider? provider;

  @override
  State<AppLanguageSelector> createState() => _AppLanguageSelectorState();
}

class _AppLanguageSelectorState extends State<AppLanguageSelector> {
  static const _boxWidth = 60.0;
  static const _boxHeight = 40.0;
  static const _itemHeight = 35.0;
  static const _gap = 2.0;

  /// Each language in its own script, used when the app's localizations
  /// are not loaded (a module preview or widget test).
  static const _fallbackLabels = {
    'en': 'English',
    'gu': 'ગુજરાતી',
    'hi': 'हिंदी',
  };

  final _link = LayerLink();
  OverlayEntry? _entry;

  LocaleProvider? get _provider =>
      widget.provider ?? Provider.of<LocaleProvider?>(context);

  Map<String, String> _labels(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return _fallbackLabels;
    return {
      'en': l10n.profileLanguageEnglishShort,
      'gu': l10n.profileLanguageGujaratiShort,
      'hi': l10n.profileLanguageHindiShort,
    };
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  void _open(LocaleProvider provider, String selectedCode) {
    if (_entry != null) return;
    final labels = _labels(context);
    final overlay = Overlay.of(context);
    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // A tap anywhere else closes the list.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomLeft,
            offset: const Offset(0, _gap),
            child: Align(
              alignment: Alignment.topLeft,
              child: _LanguageList(
                width: _boxWidth,
                itemHeight: _itemHeight,
                labels: labels,
                selectedCode: selectedCode,
                onSelected: (code) {
                  _close();
                  provider.setLocale(Locale(code));
                },
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_entry!);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    final selectedCode = provider?.locale?.languageCode ?? 'en';
    final labels = _labels(context);
    final current = labels[selectedCode] ?? labels['en']!;

    return CompositedTransformTarget(
      link: _link,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const Key('profile-language-selector'),
          borderRadius: BorderRadius.circular(20),
          onTap: provider == null ? null : () => _open(provider, selectedCode),
          child: Container(
            width: _boxWidth,
            height: _boxHeight,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cool400),
              color: AppColors.neutral50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  current.length > 2 ? current.substring(0, 2) : current,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(HomeAssets.chevronDown, width: 18, height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The list under the box: one row per language, the selected one green.
class _LanguageList extends StatelessWidget {
  const _LanguageList({
    required this.width,
    required this.itemHeight,
    required this.labels,
    required this.selectedCode,
    required this.onSelected,
  });

  final double width;
  final double itemHeight;
  final Map<String, String> labels;
  final String selectedCode;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final entries = labels.entries.toList(growable: false);
    // A solid white card: the shadow sits outside it, never behind the rows.
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cool400),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9),
        child: Material(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 0,
                    indent: 0,
                    endIndent: 0,
                    color: AppColors.neutral200,
                  ),
                InkWell(
                  key: Key('profile-language-${entries[i].key}'),
                  onTap: () => onSelected(entries[i].key),
                  child: SizedBox(
                    height: itemHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          entries[i].value,
                          maxLines: 1,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: entries[i].key == selectedCode
                                ? AppColors.primary500
                                : AppColors.neutral950,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
