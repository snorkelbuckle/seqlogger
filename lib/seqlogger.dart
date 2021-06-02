library seqlogger;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SeqResponse {
  http.Response? response;
  Object? exception;

  SeqResponse(this.response, this.exception);
}

class _SeqManager {
  Queue<String> _messages = new Queue<String>();

  // region SeqManager Fields
  String protocol = 'http';
  String host = '127.0.0.1';
  String port = '5341';
  String? apiKey;
  double minimumLevel = 2.0;
  double logLevelDefault = 2.0;
  Map<String, double> logLevels = {'Trace': 0.0, 'Debug': 1.0, 'Info': 2.0, 'Warning': 3.0, 'Error': 4.0, 'Fatal': 5.0};
  var _client = http.Client();

  //Queue
  // endregion

  // region Singleton Pattern
  static final _SeqManager _instance = _SeqManager._internal();

  factory _SeqManager() => _instance;

  _SeqManager._internal();

  // endregion

  String get endPointURI {
    var uri = '${this.protocol}://${this.host}:${this.port}/api/events/raw?clef';
    if (this.apiKey != null) {
      uri = '$uri?apiKey=${this.apiKey}';
    }
    return uri;
  }

  Future<SeqResponse> sendMessage(data) async {
    try {
      var uriResponse = await _client.post(Uri.parse(endPointURI), body: data);
      return SeqResponse(uriResponse, null);
    } catch (e) {
      return SeqResponse(null, e);
    }
  }
}

class SeqWriter {
  _SeqManager _manager = _SeqManager();
  StreamController<dynamic> _sc = StreamController();
  StreamSubscription<dynamic>? _subscription;
  bool enableErrors = false;

  // region Setters and Getters
  String get protocol => _manager.protocol;

  String get host => _manager.host;

  String get port => _manager.port;

  String? get apiKey => _manager.apiKey;

  double get minimumLevel => _manager.minimumLevel;

  double get logLevelDefault => _manager.logLevelDefault;

  Map<String, double> get logLevels => _manager.logLevels;

  set protocol(String value) {
    _manager.protocol = value;
  }

  set host(String value) {
    _manager.host = value;
  }

  set port(String value) {
    _manager.port = value;
  }

  set apiKey(String? value) {
    _manager.apiKey = value;
  }

  set minimumLevel(double value) {
    _manager.minimumLevel = value;
  }

  set logLevelDefault(double value) {
    _manager.logLevelDefault = value;
  }

  set logLevels(Map<String, double> value) {
    _manager.logLevels = value;
  }

  // endregion

  SeqWriter() {
    this._subscription =
        _sc.stream.listen(dataHandler, onError: errorHandler, cancelOnError: false, onDone: doneHandler);
  }

  void onError(Function? handleError) {
    if (handleError == null)
      this._subscription!.onError(errorHandler);
    else
      this._subscription!.onError(handleError);
  }

  // region Event handlers
  dataHandler(dynamic data) async {
    print(data);
    //_manager.sendMessage(data);
    var seqResponse = await _manager.sendMessage(data);
    //_sc.addError(seqResponse);
  }

  void errorHandler(Object error) {
    // We silently ignore errors.
    if (!enableErrors) return;
    var sr = error as SeqResponse;
    if (sr.response != null) {
      print('Status Code: ${sr.response!.statusCode}');
    } else {
      print('Exception: ${sr.exception.toString()}');
    }

    // TODO: check for network timeout and if timed out, then implement backoff strategy
    // TODO: so as not to delay program execution or use excessive resources
  }

  doneHandler() {
    print('Stream is done!');
  }

  // endregion

  double? levelValue(String level) {
    if (logLevels.containsKey('${level[0].toUpperCase()}${level.substring(1).toLowerCase()}')) {
      return logLevels['${level[0].toUpperCase()}${level.substring(1).toLowerCase()}'];
    } else {
      return logLevelDefault;
    }
  }

  String log(
      {String? level,
        String? message,
        Map<String, dynamic>? templateValues,
        Map<String, dynamic>? userProperties,
        String? exception}) {

    var json = _createJson(
        level: level,
        message: message,
        templateValues: templateValues,
        userProperties: userProperties,
        exception: exception);

    _sc.sink.add(json);
    return json;
  }

  String _createJson(
      {String? level,
        String? message,
        Map<String, dynamic>? templateValues,
        Map<String, dynamic>? userProperties,
        String? exception}) {
    var _jsonMsg = new Map();
    _jsonMsg['@t'] = DateTime.now().toIso8601String();
    _jsonMsg['@l'] = level ?? 'Info';
    if (templateValues != null) {
      _jsonMsg['@mt'] = message ?? '';
      templateValues.forEach((key, value) {
        _jsonMsg[key] = value;
      });
    } else {
      _jsonMsg['@m'] = message ?? '';
    }
    if (userProperties != null) {
      userProperties.forEach((key, value) {
        _jsonMsg[key] = value;
      });
    }
    if (exception != null) _jsonMsg['@x'] = exception;

    //var json = jsonEncode(_jsonMsg);
    return jsonEncode(_jsonMsg);
  }
}
