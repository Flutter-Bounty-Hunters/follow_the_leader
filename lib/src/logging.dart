// ignore_for_file: avoid_print

import 'package:logging/logging.dart';

/// Follow the Leader logger names.
class LogNames {
  static const leader = 'flt.leader';
  static const follower = 'flt.follower';
  static const link = 'flt.link';
  static const boundary = 'flt.boundary';
  static const widgetBoundary = 'flt.boundary.widget';
  static const _root = 'flt';
}

/// Follow the Leader logging.
class FtlLogs {
  static final leader = Logger(LogNames.leader);
  static final follower = Logger(LogNames.follower);
  static final link = Logger(LogNames.link);
  static final boundary = Logger(LogNames.boundary);
  static final widgetBoundary = Logger(LogNames.widgetBoundary);
  static final _root = Logger(LogNames._root);

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
