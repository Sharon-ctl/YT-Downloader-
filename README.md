# YTDL Toolkit

**YTDL Toolkit** is a powerful, zero-knowledge-required Windows application for downloading video, audio, playlists, livestreams, clips, subtitles, and metadata from YouTube and thousands of supported websites. Powered by `yt-dlp` and `FFmpeg`, it wraps the complexity of command-line media tools into a beautiful, intuitive, wizard-style interactive menu.

---

## Features

*   **Wizard-Style Interface:** No complex command-line arguments to memorize. Simple numbers-based menus guide you through every choice.
*   **Automatic Clipboard Detection:** When prompted for a URL, copied links are detected automatically — simply press `Enter` to download!
*   **Built-in YouTube Search:** Search YouTube directly from inside the terminal and download without ever opening your web browser.
*   **Time-Range & Clip Downloader:** Download exact video or audio segments by specifying start and end timestamps (e.g. `01:30` to `02:45`).
*   **Accelerated Multi-Threaded Downloads:** Downloads multiple video/audio fragments in parallel (up to 16 concurrent threads) for blazing-fast download speeds.
*   **Massive Format Support:** Download everything from MP3s and lossless FLAC audio to lightweight H.264 clips and ultra-high-quality 4K AV1 videos.
*   **SponsorBlock Integration:** Automatically detect and remove sponsor segments, intros, outros, and self-promotion from downloaded videos.
*   **Embedded Subtitles & Chapters:** Embed multilingual subtitles and chapter markers directly into your output MP4/MKV video files.
*   **Batch & Playlist Modes:** Queue multiple URLs manually or load an entire text file (`urls.txt`). Download complete playlists in normal or reverse chronological order.
*   **Intelligent File Handling & Archive:** Downloads are processed in temporary folders before final placement (**100% OneDrive & Google Drive friendly**). Automatically remembers downloaded items to avoid duplicate downloads, with smart re-download prompts if files were deleted.
*   **Adobe Premiere Pro Lossless Workflow:** Download directly or convert existing files to **Apple ProRes 422 HQ (.mov)** (10-bit intra-frame, uncompressed PCM 48kHz audio, zero scrub lag) or **Lossless H.264 (.mp4)** (CRF 0, YUV420p) for immediate, stutter-free timeline editing.
*   **File Converter:** Convert any existing local media files between Apple ProRes (.mov), Lossless H.264, Fast Remux, Avid DNxHD/HR, MP4, MKV, AVI, WAV (24-bit 48kHz), MP3, FLAC, and M4A with live conversion progress.
*   **Fully Automatic Setup:** On first launch, the toolkit automatically checks, installs, and manages the correct versions of `yt-dlp` and `FFmpeg`.

---

## Installation & Getting Started

1. **Download or Clone the Toolkit:** Place the folder anywhere on your PC (`Documents`, `Desktop`, etc.).
2. **Launch the Application:** Double-click `Launcher.bat`.
    *   *Note: Ensure you are connected to the internet on first launch so the toolkit can automatically fetch `yt-dlp` and `FFmpeg`.*
3. **Start Downloading:** Select an option from the menu:
    *   `1` — Download Video (with preferred/custom quality)
    *   `2` — Download Audio (MP3, FLAC, WAV, M4A, OPUS)
    *   `3` — Download a specific Clip / Time Range
    *   `4` — Search YouTube and download results
    *   `5` — Download Playlists (full, range, or reverse)
    *   `7` — Batch download from console or text file

---

## Configuration & Settings

Open **Settings (Option 15)** from the main menu to customize:

*   **Download Folder:** Set custom folders for videos, music, playlists, and metadata.
*   **Preferred Codecs & Formats:** Set default quality (e.g., `1080p`, `h264`, `mp3`, `320k`) to download with a single press.
*   **Concurrent Threads:** Configure parallel download fragments (default `4`, up to `16`).
*   **Speed Limit:** Limit bandwidth usage (e.g. `5M`, `500K`) or set `0` for unlimited.
*   **Embed Subtitles & Chapters:** Toggle automatic subtitle and chapter embedding into video files.
*   **Themes:** Choose from 5 console color themes (`Classic`, `Blue`, `Green`, `Purple`, `White`).
*   **Browser Cookies:** Link your browser (`chrome`, `edge`, `firefox`, `brave`) to download age-restricted or members-only videos.

---

## Troubleshooting

### "Sign in to confirm you're not a bot" / Age Restrictions
YouTube often blocks automated requests.
**Fix:** Open **Settings -> Browser Cookies (Option 18)**. Select your primary browser (`chrome`, `edge`, `firefox`, `brave`). The toolkit will use your existing login session securely.

### YouTube downloads fail or "Requested format is not available"
yt-dlp needs a JavaScript runtime to download from YouTube. The toolkit installs **Deno** automatically into the `tools` folder on startup and passes it to yt-dlp. If YouTube downloads still fail, delete `tools\deno.exe` and restart the toolkit to reinstall it, then check **Maintenance (Option 16)** to update yt-dlp.

### "No internet connection detected" but your internet works
The startup check tries to open HTTPS connections to GitHub, YouTube and Google (so it follows your system proxy). If you chose "continue offline" by mistake, you do not need to restart: the toolkit rechecks the connection when you start a download.

### File Lock Errors / Write Permissions
Ensure your folder is unzipped and not in a system-restricted directory like `C:\Windows\System32`. Use `Documents` or `Desktop`.

### Corrupted Dependencies
If yt-dlp or FFmpeg encounters issues, go to **Maintenance (Option 16)** and select **Reinstall yt-dlp** or **Reinstall FFmpeg**.

---

## License & Credits

Released under the MIT License.
*   [yt-dlp](https://github.com/yt-dlp/yt-dlp)
*   [FFmpeg](https://ffmpeg.org/) (Windows builds courtesy of [gyan.dev](https://www.gyan.dev/))
