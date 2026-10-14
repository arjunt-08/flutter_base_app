import 'package:flutter_application_1/application/core/theme/theme/theme_cubit.dart';
import 'package:flutter_application_1/application/core/utils/enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ThemeCubit themeCubit;

  setUp(() {
    themeCubit = ThemeCubit();
  });

  tearDown(() {
    themeCubit.close();
  });

  test('initial state should have light theme and index 0', () {
    expect(themeCubit.state.themeMode, equals(AppThemeMode.light));
    expect(themeCubit.state.index, equals(0));
  });

  test('changeTheme updates state with new themeMode', () async {
    themeCubit.changeTheme(AppThemeMode.dark);
    expect(themeCubit.state.themeMode, equals(AppThemeMode.dark));
  });

  test('setIndex updates index in state', () {
    themeCubit.setIndex(2);
    expect(themeCubit.state.index, equals(2));
  });
}
