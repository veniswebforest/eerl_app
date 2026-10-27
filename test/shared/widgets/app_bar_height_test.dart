import 'package:eerl_app/core/theme/app_dimensions.dart';
import 'package:eerl_app/core/theme/app_theme.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all app bar variants use the shared height', () {
    const customAppBar = CustomAppBar();
    const supervisorHeader = SupervisorTaskHeader(title: 'Tasks');

    expect(customAppBar.preferredSize.height, AppScreenHeaderMetrics.height);
    expect(
      supervisorHeader.preferredSize.height,
      AppScreenHeaderMetrics.height,
    );
    expect(
      AppTheme.lightTheme.appBarTheme.toolbarHeight,
      AppScreenHeaderMetrics.height,
    );
    expect(
      AppTheme.darkTheme.appBarTheme.toolbarHeight,
      AppScreenHeaderMetrics.height,
    );
  });
}
