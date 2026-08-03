# YTDL Toolkit

**YTDL Toolkit** is a powerful, zero-knowledge-required Windows application for downloading video, audio, playlists, livestreams, subtitles, and metadata from thousands of supported websites. Powered by `yt-dlp` and `FFmpeg`, it wraps the complexity of command-line media tools into a beautiful, intuitive, wizard-style interactive menu.

---

## Features

*   **Wizard-Style Interface:** No complex command-line arguments to memorize. Just paste a URL and choose your desired format from simple menus.
*   **Massive Format Support:** Download everything from MP3s and lossless FLAC audio to lightweight H.264 clips and ultra-high-quality 4K AV1 videos.
*   **Fully Automatic Setup:** Simply run the launcher. The toolkit automatically downloads, installs, and manages the correct versions of `yt-dlp` and `FFmpeg` for you.
*   **Intelligent File Handling:** Downloads are safely processed in local Windows temporary folders before being moved to your final directory. This makes the toolkit **100% compatible with OneDrive and Google Drive syncing folders** without causing file lock crashes.
*   **Advanced Capabilities:** 
    *   Download massive playlists
    *   Record active livestreams
    *   Download in bulk via Batch mode
    *   Extract thumbnails and subtitles
    *   Use SponsorBlock to automatically remove intro/outro/sponsor segments
*   **Built-in Maintenance:** Integrated tools for checking dependencies, repairing configurations, clearing caches, and reading session logs.

---

## Installation & Getting Started

1. **Download the Toolkit:** Download the toolkit folder and place it anywhere on your PC (Desktop, Documents, etc.).
2. **Launch the Application:** Double-click the `Launcher.bat` file.
    *   *Note: Ensure you are connected to the internet on first launch. The toolkit will automatically download its required background dependencies (`yt-dlp` and `FFmpeg`).*
3. **Start Downloading:** From the main menu, press `1` to download a video or `2` to download audio. Follow the on-screen prompts!

---

## Configuration & Settings

You can customize the toolkit's behavior by selecting **Settings (Option 13)** from the main menu. 

Key settings include:
*   **Download Folder:** Change where your downloaded files are saved. By default, they are sorted into organized folders (Videos, Music, Playlists, etc.) inside the toolkit directory.
*   **Preferred Codecs & Formats:** Set your favorite video/audio formats to streamline the download process.
*   **Themes:** Change the terminal colors to match your style.
*   **Browser Cookies:** Easily link the toolkit to your web browser (Chrome, Edge, Firefox, etc.) to securely bypass age restrictions or bot-detection screens!

---

## Troubleshooting

If a download fails or behaves unexpectedly, try these built-in fixes:

### "Sign in to confirm you're not a bot" / "Sign in to confirm your age"
YouTube aggressively blocks automated downloads. 
**Fix:** Open the Toolkit, go to **Tools -> Settings -> Browser Cookies** (Option 14). Type the name of the browser you use for YouTube (e.g., `chrome`, `edge`, `firefox`, `brave`). The toolkit will use your browser's login session to authenticate you securely.

### File Lock Errors / Write Permission Errors
Ensure that your toolkit folder is fully extracted from its ZIP file. If you are experiencing permission errors, try moving the folder to your `Desktop` or `Documents`.

### Corrupted Dependencies
If `yt-dlp` or `FFmpeg` becomes corrupted or outdated, go to **Maintenance** (Option 14 from the main menu) and select the option to reinstall them.

### View Detailed Logs
If something goes wrong, the toolkit records every action. Go to **Maintenance -> View Logs** (Option 11) to read the exact error outputs for debugging.

---

## License & Credits

This project is open-source under the MIT License.

*   **yt-dlp:** Powered by the incredible [yt-dlp project](https://github.com/yt-dlp/yt-dlp).
*   **FFmpeg:** Media processing powered by [FFmpeg](https://ffmpeg.org/). Windows essentials builds provided by [gyan.dev](https://www.gyan.dev/).
