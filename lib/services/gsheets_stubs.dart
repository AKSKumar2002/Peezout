
// Stub classes for web compatibility to avoid importing gsheets package on web
// This limits functionality on web (no real Sheets connection) but allows the app to run.

class GSheets {
  GSheets(String credentials);
  Future<Spreadsheet?> spreadsheet(String id) async => null;
}

class Spreadsheet {
  Worksheet? worksheetByTitle(String title) => null;
  Future<Worksheet?> addWorksheet(String title) async => null;
}

class Worksheet {
  WorksheetValues get values => WorksheetValues();
  Future<bool> deleteRow(int index) async => false;
}

class WorksheetValues {
  Future<void> insertRow(int row, List<dynamic> values) async {}
  Future<void> appendRow(List<dynamic> values) async {}
  // insertValue signature in real package: Future<bool> insertValue(Object value, {required int column, required int row});
  // The service uses: insertValue(val, column: c, row: r)
  Future<bool> insertValue(dynamic value, {required int column, required int row}) async => false;
  
  Future<List<List<String>>> allRows() async => [];
  // signature in package is Future<List<List<String>>> or similar?
  // The service code expects: List<List<dynamic>> or List<List<String>>
  // Service usage: final allRows = await ...; allRows[i][0]
}
