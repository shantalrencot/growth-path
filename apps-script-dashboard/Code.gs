// ============================================================
// Personality Assessment Dashboard — Code.gs
// Paste this into Apps Script (Extensions → Apps Script)
// ============================================================

var SHEET_NAME = 'Form Responses 1'; // change if your tab has a different name

// Column indices (0-based) — adjust if your sheet differs
var COL = {
  TIMESTAMP:    0,
  FIRST_NAME:   1,
  LAST_NAME:    2,
  EMAIL:        3,
  COMPANY:      4,
  ANIMAL1:      5,
  ANIMAL2:      6,
  STATUS:       14  // the last STATUS column
};

// ----------------------------------------------------------------
// Called by the web dashboard to fetch data
// ----------------------------------------------------------------
function getDashboardData() {
  var ss    = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName(SHEET_NAME);
  if (!sheet) return { error: 'Sheet "' + SHEET_NAME + '" not found.' };

  var rows = sheet.getDataRange().getValues();
  rows.shift(); // remove header row

  var companies = {};

  rows.forEach(function(row) {
    var company   = (row[COL.COMPANY]    || '').toString().trim();
    var firstName = (row[COL.FIRST_NAME] || '').toString().trim();
    var lastName  = (row[COL.LAST_NAME]  || '').toString().trim();
    var email     = (row[COL.EMAIL]      || '').toString().trim();
    var timestamp = row[COL.TIMESTAMP];
    var status    = (row[COL.STATUS]     || '').toString().trim().toUpperCase();

    if (!company) company = '(No Company)';

    if (!companies[company]) {
      companies[company] = { name: company, total: 0, done: 0, error: 0, people: [] };
    }

    var isDone = status === 'DONE';
    companies[company].total++;
    if (isDone) companies[company].done++;
    else        companies[company].error++;

    companies[company].people.push({
      name:      (firstName + ' ' + lastName).trim() || email || '(Unknown)',
      email:     email,
      timestamp: timestamp ? new Date(timestamp).toLocaleString() : '',
      status:    status || 'PENDING'
    });
  });

  // Sort companies alphabetically
  var list = Object.values(companies).sort(function(a, b) {
    return a.name.localeCompare(b.name);
  });

  return {
    updated:   new Date().toLocaleString(),
    total:     rows.length,
    companies: list
  };
}

// ----------------------------------------------------------------
// Serves the web app
// ----------------------------------------------------------------
function doGet() {
  return HtmlService
    .createHtmlOutputFromFile('Dashboard')
    .setTitle('Personality Assessment Tracker')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}
