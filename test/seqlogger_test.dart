import 'package:flutter_test/flutter_test.dart';
import 'package:seqlogger/seqlogger.dart';

void main() {
  var myLog = SeqWriter();
  group('SeqWriter Fields', ()
  {
    test('default values', (){
      expect(myLog.protocol,'http');
      expect(myLog.host,'127.0.0.1');
      expect(myLog.port,'5341');
      expect(myLog.apiKey,null);
      expect(myLog.minimumLevel, 2.0);
      expect(myLog.logLevelDefault, 2.0);
      Map<String, double> _logLevels = {'Trace': 0.0, 'Debug': 1.0, 'Info': 2.0, 'Warning': 3.0, 'Error': 4.0, 'Fatal': 5.0};
      expect(myLog.logLevels, _logLevels);
    });
    test('SeqWriter setters and getters', (){
      myLog.protocol = 'https';
      expect(myLog.protocol, 'https');
      myLog.host = '127.0.0.2';
      expect(myLog.host, '127.0.0.2');
      myLog.port = '85341';
      expect(myLog.port, '85341');
      myLog.apiKey = 'someApiKey';
      expect(myLog.apiKey, 'someApiKey');
      myLog.minimumLevel = 1.5;
      expect(myLog.minimumLevel, 1.5);
      myLog.logLevelDefault = 0.2;
      expect(myLog.logLevelDefault, 0.2);
      Map<String, double> _logLevels2 = {'Trace': 0.0, 'Debug': 0.2, 'Info': 2.0, 'Error': 4.0, 'Critical': 4.5};
      myLog.logLevels = _logLevels2;
      expect(myLog.logLevels, _logLevels2);
      _logLevels2['Super'] = 6.0;
      expect(myLog.logLevels, _logLevels2);
    });
  });
}
