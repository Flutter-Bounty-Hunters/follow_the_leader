// ignore_for_file: avoid_print

import 'package:logging/logging.dart';

/// Follow the Leader logger names.
abstract class FtlLogNames {
  static const leader = 'ftl.leader';
  static const follower = 'ftl.follower';
  static const link = 'ftl.link';
  static const boundary = 'ftl.boundary';
  static const widgetBoundary = 'ftl.boundary.widget';
  static const _root = 'ftl';
}

/// Follow the Leader logging.
abstract class FtlLogs {
  static final leader = Logger(FtlLogNames.leader);
  static final follower = Logger(FtlLogNames.follower);
  static final link = Logger(FtlLogNames.link);
  static final boundary = Logger(FtlLogNames.boundary);
  static final widgetBoundary = Logger(FtlLogNames.widgetBoundary);
  static final _root = Logger(FtlLogNames._root);

  static final _activeLoggers = <Logger>{};

  /// Initialize the given [loggers] using the minimum [level].
  ///
  /// To enable all the loggers, use [FtlLogs.initAllLogs].
  static void initLoggers(Set<Logger> loggers, [Level level = Level.ALL]) {
    hierarchicalLoggingEnabled = true;

    for (final logger in loggers) {
      if (!_activeLoggers.contains(logger)) {
        print('Initializing logger: ${logger.name}');
        logger
          ..level = level
          ..onRecord.listen(_printLog);

        _activeLoggers.add(logger);
      }
    }
  }

  /// Initializes all the available loggers.
  ///
  /// To control which loggers are initialized, use [FtlLogs.initLoggers].
  static void initAllLogs([Level level = Level.ALL]) {
    initLoggers({_root}, level);
  }

  /// Returns `true` if the given [logger] is currently logging, or
  /// `false` otherwise.
  ///
  /// Generally, developers should call loggers, regardless of whether
  /// a given logger is active. However, sometimes you may want to log
  /// information that's costly to compute. In such a case, you can
  /// choose to compute the expensive information only if the given
  /// logger will actually log the information.
  static bool isLogActive(Logger logger) {
    return _activeLoggers.contains(logger);
  }

  /// Deactivates the given [loggers].
  static void deactivateLoggers(Set<Logger> loggers) {
    for (final logger in loggers) {
      if (_activeLoggers.contains(logger)) {
        print('Deactivating logger: ${logger.name}');
        logger.clearListeners();

        _activeLoggers.remove(logger);
      }
    }
  }

  /// Logs a record using a print statement.
  static void _printLog(LogRecord record) {
    print(
        '(${record.time.second}.${record.time.millisecond.toString().padLeft(3, '0')}) ${record.loggerName} > ${record.level.name}: ${record.message}');
  }
}
