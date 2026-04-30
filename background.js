// =============================================================================
// background.js — Service worker for the "Open in mpv" browser extension
//
// Creates a right-click context menu on all links. When clicked, it sends
// the link URL to the native messaging host, which launches mpv.
//
// License: MIT
// =============================================================================

// ---- Context Menu Setup -----------------------------------------------------

// Create the right-click menu entry when the extension is installed
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: "open-in-mpv",
    title: "Open in mpv",
    // Show on links and also on the page itself (for the current page URL)
    contexts: ["link", "page", "video", "audio"],
  });
});

// ---- Context Menu Click Handler ---------------------------------------------

chrome.contextMenus.onClicked.addListener((info, tab) => {
  // Prefer the link URL; fall back to the page URL
  const url = info.linkUrl || info.srcUrl || info.pageUrl;

  if (!url) {
    console.error("[Open in mpv] No URL found.");
    return;
  }

  console.log(`[Open in mpv] Sending URL to native host: ${url}`);

  // Send the URL to the native messaging host (open-in-mpv)
  // The native host will launch mpv with the URL
  chrome.runtime.sendNativeMessage(
    "com.open_in_mpv",
    { url: url },
    (response) => {
      if (chrome.runtime.lastError) {
        console.error(
          "[Open in mpv] Native messaging error:",
          chrome.runtime.lastError.message
        );
        // Fallback: open the mpv:// protocol URL
        // This works if the .desktop URL handler is installed
        console.log("[Open in mpv] Falling back to mpv:// protocol handler...");
        chrome.tabs.update(tab.id, {
          url: `mpv://${encodeURIComponent(url)}`,
        });
        return;
      }
      console.log("[Open in mpv] Response:", response);
    }
  );
});
