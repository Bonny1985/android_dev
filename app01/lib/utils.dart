String boolToString(bool b) {
  return b ? 'true' : 'false';
}

bool isTrue(String? b) {
  return b != null ? b.trim().toLowerCase().compareTo("true") == 0 : false;
}
