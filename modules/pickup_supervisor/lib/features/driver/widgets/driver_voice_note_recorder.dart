import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';
import 'package:record/record.dart';

const _assetPackage = 'pickup_supervisor';
const _microphoneAsset = 'assets/icons/driver/stop_detail_v2/mic.svg';

/// A reusable, press-and-hold voice-note control for driver collection forms.
///
/// Audio is recorded to the device temporary directory and capped at one
/// minute, matching the collection-form design.
class DriverVoiceNoteRecorder extends StatefulWidget {
  const DriverVoiceNoteRecorder({super.key, this.onRecordingChanged});

  final ValueChanged<String?>? onRecordingChanged;

  @override
  State<DriverVoiceNoteRecorder> createState() =>
      _DriverVoiceNoteRecorderState();
}

class _DriverVoiceNoteRecorderState extends State<DriverVoiceNoteRecorder> {
  static const _maximumDuration = Duration(minutes: 1);

  AudioRecorder? _recorder;
  AudioPlayer? _player;
  Timer? _timer;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<void>? _completionSubscription;
  Duration _elapsed = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  Duration _recordedDuration = Duration.zero;
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _pressHeld = false;
  String? _recordingPath;

  Future<void> _startRecording() async {
    if (_isRecording) return;
    _pressHeld = true;
    try {
      final recorder = _recorder ??= AudioRecorder();
      final hasPermission = await recorder.hasPermission();
      if (!mounted || !_pressHeld) return;
      if (!hasPermission) {
        _showMessage(
          DriverLocalizations.of(context).microphonePermissionRequired,
        );
        return;
      }

      final path =
          '${Directory.systemTemp.path}/driver_voice_note_${DateTime.now().microsecondsSinceEpoch}.m4a';
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          noiseSuppress: true,
          echoCancel: true,
        ),
        path: path,
      );
      if (!mounted) {
        await recorder.stop();
        return;
      }
      if (!_pressHeld) {
        await recorder.stop();
        return;
      }

      await _discardPreviousRecording();

      setState(() {
        _recordingPath = null;
        _elapsed = Duration.zero;
        _isRecording = true;
      });
      widget.onRecordingChanged?.call(null);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final next = _elapsed + const Duration(seconds: 1);
        setState(() => _elapsed = next);
        if (next >= _maximumDuration) unawaited(_stopRecording());
      });
    } catch (_) {
      if (mounted) {
        _showMessage(DriverLocalizations.of(context).voiceNoteRecordingFailed);
      }
    }
  }

  Future<void> _stopRecording() async {
    _pressHeld = false;
    if (!_isRecording) return;
    _timer?.cancel();
    _timer = null;
    try {
      final path = await _recorder?.stop();
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _recordingPath = path;
        _recordedDuration = _elapsed;
        _playbackPosition = Duration.zero;
      });
      widget.onRecordingChanged?.call(path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isRecording = false);
      _showMessage(DriverLocalizations.of(context).voiceNoteRecordingFailed);
    }
  }

  void _initializePlayerListeners(AudioPlayer player) {
    _positionSubscription ??= player.onPositionChanged.listen((position) {
      if (mounted) setState(() => _playbackPosition = position);
    });
    _durationSubscription ??= player.onDurationChanged.listen((duration) {
      if (mounted && duration > Duration.zero) {
        setState(() => _recordedDuration = duration);
      }
    });
    _playerStateSubscription ??= player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _completionSubscription ??= player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playbackPosition = Duration.zero;
        });
      }
    });
  }

  Future<void> _togglePlayback() async {
    final path = _recordingPath;
    if (path == null) return;
    try {
      final player = _player ??= AudioPlayer();
      _initializePlayerListeners(player);
      if (_isPlaying) {
        await player.pause();
      } else if (_playbackPosition > Duration.zero) {
        await player.resume();
      } else {
        await player.play(DeviceFileSource(path));
      }
    } catch (_) {
      if (mounted) {
        _showMessage(DriverLocalizations.of(context).voiceNotePlaybackFailed);
      }
    }
  }

  Future<void> _discardPreviousRecording() async {
    await _player?.stop();
    final path = _recordingPath;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    if (!mounted) return;
    setState(() {
      _recordingPath = null;
      _isPlaying = false;
      _playbackPosition = Duration.zero;
      _recordedDuration = Duration.zero;
    });
  }

  Future<void> _removeRecording() async {
    await _discardPreviousRecording();
    if (!mounted) return;
    setState(() => _elapsed = Duration.zero);
    widget.onRecordingChanged?.call(null);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 60);
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_positionSubscription?.cancel());
    unawaited(_durationSubscription?.cancel());
    unawaited(_playerStateSubscription?.cancel());
    unawaited(_completionSubscription?.cancel());
    final player = _player;
    if (player != null) unawaited(player.dispose());
    final recorder = _recorder;
    if (recorder != null) {
      if (_isRecording) unawaited(recorder.cancel());
      unawaited(recorder.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final recorded = _recordingPath != null;
    final title = _isRecording
        ? l10n.recordingVoiceNote
        : recorded
        ? l10n.voiceNoteRecorded
        : l10n.holdToRecordVoiceNote;

    return Column(
      children: [
        Semantics(
          button: true,
          label: title,
          child: GestureDetector(
            key: const Key('driver-voice-note-recorder'),
            behavior: HitTestBehavior.opaque,
            onLongPressStart: (_) => unawaited(_startRecording()),
            onLongPressEnd: (_) => unawaited(_stopRecording()),
            onLongPressCancel: () => unawaited(_stopRecording()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              decoration: BoxDecoration(
                color: DriverColors.surface,
                border: Border.all(
                  color: _isRecording
                      ? DriverColors.primary500
                      : DriverColors.cool400,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: DriverColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      _microphoneAsset,
                      package: _assetPackage,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DriverTextStyles.semibold14.copyWith(
                            color: DriverColors.neutral950,
                          ),
                        ),
                        Text(
                          l10n.upToOneMinute,
                          style: DriverTextStyles.medium12.copyWith(
                            color: DriverColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDuration(_elapsed),
                    style: DriverTextStyles.medium14.copyWith(
                      color: DriverColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (recorded) ...[
          const SizedBox(height: 8),
          DriverVoicePlaybackCard(
            isPlaying: _isPlaying,
            position: _playbackPosition,
            duration: _recordedDuration,
            onPlayPause: () => unawaited(_togglePlayback()),
            onRemove: () => unawaited(_removeRecording()),
          ),
        ],
      ],
    );
  }
}

class DriverVoicePlaybackCard extends StatelessWidget {
  const DriverVoicePlaybackCard({
    super.key,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onRemove,
  });

  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onRemove;

  String _formatDuration(Duration value) {
    final seconds = value.inSeconds.clamp(0, 3599);
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final totalMilliseconds = duration.inMilliseconds;
    final progress = totalMilliseconds <= 0
        ? 0.0
        : (position.inMilliseconds / totalMilliseconds).clamp(0.0, 1.0);
    return Container(
      key: const Key('driver-voice-playback-card'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: DriverColors.primary50,
        border: Border.all(color: DriverColors.summaryBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton.filled(
            key: const Key('driver-voice-play-pause'),
            tooltip: isPlaying ? l10n.pauseVoiceNote : l10n.playVoiceNote,
            onPressed: onPlayPause,
            style: IconButton.styleFrom(
              backgroundColor: DriverColors.primary500,
              foregroundColor: DriverColors.surface,
              minimumSize: const Size(40, 40),
              padding: EdgeInsets.zero,
            ),
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.voiceNoteRecorded,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    key: const Key('driver-voice-progress'),
                    value: progress,
                    minHeight: 4,
                    backgroundColor: DriverColors.cool200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      DriverColors.primary500,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: const Key('driver-voice-remove'),
            tooltip: l10n.removeVoiceNote,
            onPressed: onRemove,
            color: DriverColors.red600,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}
