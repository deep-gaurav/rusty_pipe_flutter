String humanizeNumber(int number) {
  if (number / 1000000000 > 1) {
    return (number / 1000000000).toStringAsFixed(2) + "B";
  } else if (number / 1000000 > 1) {
    return (number / 1000000).toStringAsFixed(2) + "M";
  } else if (number / 1000 > 1) {
    return (number / 1000).toStringAsFixed(2) + "K";
  } else {
    return number.toString();
  }
}

String humanizeDuration(Duration duration) {
  var result = "";
  if (duration.inHours > 0) {
    result += duration.inHours.toString() + ":";
  }
  if (duration.inMinutes > 0) {
    result += (duration.inMinutes % 60)
            .toString()
            .padLeft(result.isNotEmpty ? 2 : 1, '0') +
        ":";
  }
  result += (duration.inSeconds % 60).toString().padLeft(2, '0');
  return result;
}
