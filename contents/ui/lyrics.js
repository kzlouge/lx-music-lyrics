function loadLyrics(lyricsLabel) {
  if (typeof EventSource !== "undefined") {
  } else {
    console.error("SSE not supported in this browser.");
  }
}
