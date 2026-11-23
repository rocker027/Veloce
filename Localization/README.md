# Localization

Search speaks English and Traditional Chinese as written in Taiwan (`zh-Hant`). It picks the first language in System Settings › General › Language & Region that it has words for, and falls back to English.

## How it works

- English is the source. Each string in the code is its own key, so English needs no table: `en.lproj` stays empty, and `build.sh` creates it to say the app speaks English.
- `zh-Hant.lproj/Localizable.strings` holds the Chinese for every key. `zh-Hant.lproj/InfoPlist.strings` holds the permission prompts and the names Finder shows, keyed by their `Info.plist` keys.
- `build.sh` copies every `*.lproj` here into `Search.app/Contents/Resources/`, and lists the languages in `CFBundleLocalizations`.
- `Wording.language` is the language the app is showing, for the few views that set a locale of their own (`InternalPages.swift`).

## In the code

| Where the words are | What to write |
|---|---|
| A SwiftUI view or modifier with a literal: `Text("…")`, `Button("…")`, `Toggle("…", isOn:)`, `Label("…", systemImage:)`, `.help("…")` | Nothing. SwiftUI looks the literal up itself. |
| A `String`: a property, a parameter, an AppKit title, an `NSAlert`, a menu item, a tooltip | `String(localized: "…")` |
| Words with a value in them | `String(localized: "Closed \(count) tabs")`. The key is `"Closed %lld tabs"`: an `Int` is `%lld`, a `String` is `%@`. A `Double` would print as `2.500000`: format it to a `String` first. In the table the key keeps plain `%@`; only the translation reorders with `%1$@`, `%2$@`. |
| Singular and plural | Two whole sentences, `count == 1 ? String(localized: "1 tab") : String(localized: "\(count) tabs")`. Never glue `"tab" + "s"`. |
| `SettingsIndex` titles, details and "more" lines | English stays in the row (the ⌘F find matches it, and the bench reads it). The row is translated where it is drawn. |
| Words also stored or handed on: a tab's `failure` (an agent reads it), a sleep reason (the bench reads it) | Keep the English literal, and translate where it is drawn with `Wording.shown(…)`. `check.py` doesn't see these keys; add them to the table by hand. |
| The name a new space, group or folder starts with | `String(localized:)`: it is the person's own content from then on, like Finder's "untitled folder". Not a fallback filled in while syncing, which another Mac reads: that stays English. |

Leave alone: defaults keys and identifiers, anything persisted or compared with `==`, log lines, JavaScript and CSS, what extensions read (Chrome API errors stay as Chrome writes them), prompts sent to a model, the AppleScript dictionary, `Bench.swift`, and the names Search, Arc, Safari, Chrome and other products.

Tests launch the app with `-AppleLanguages (en)`: the bench finds menus by their English titles.

## Checking

```sh
python3 Localization/check.py           # every key in the code, against every table
python3 Localization/check.py Sources/Search/Spaces.swift
```

It lists keys with no translation and translations whose `%` specifiers don't match their key's, and exits 1 if there are any.

## Words (zh-Hant)

Taiwan's usage, close to macOS's own where macOS has one. A half-width space between Chinese and Latin letters or digits. Full-width punctuation: ，。：；？！「」（）. `…` becomes `⋯`. Address the reader as 你.

| English | 中文 |
|---|---|
| tab | 分頁 |
| new tab | 新分頁 |
| pin, pinned | 釘選、已釘選 |
| space (Arc-style) | 空間 |
| tab group | 分頁群組 |
| column (the tabs down the side) | 側欄 |
| sidebar | 側邊欄 |
| peek | 預覽視窗 |
| split view | 分割顯示 |
| sleep (a tab) | 休眠 |
| window, full screen | 視窗、全螢幕 |
| address, address field | 網址、網址欄 |
| page, site / website, link | 網頁、網站、連結 |
| bookmark, bookmarks bar | 書籤、書籤列 |
| history | 瀏覽記錄 |
| downloads | 下載項目 |
| reading mode / reader | 閱讀模式 |
| picture in picture | 子母畫面 |
| private | 私密 |
| profile | 設定檔 |
| extension | 延伸功能 |
| settings | 設定 |
| password, passkey, keychain | 密碼、通行密鑰、鑰匙圈 |
| account, sign in, sign out | 帳號、登入、登出 |
| verification code | 驗證碼 |
| ad blocker, tracker | 廣告阻擋、追蹤器 |
| search engine | 搜尋引擎 |
| proxy | 代理伺服器 |
| folder, file | 檔案夾、檔案 |
| image, video, sound | 圖片、影片、聲音 |
| icon, menu, menu bar, toolbar | 圖示、選單、選單列、工具列 |
| shortcut | 快速鍵 |
| click, double-click, right-click, drag | 按一下、按兩下、按右鍵、拖移 |
| open, close, quit | 打開、關閉、結束 |
| turn on, turn off | 開啟、關閉 |
| copy, paste, duplicate | 拷貝、貼上、複製 |
| undo, redo | 還原、重做 |
| save, delete, remove | 儲存、刪除、移除 |
| default | 預設 |
| bring over (from another browser), Bring Things Over | 匯入、匯入資料 |
| update | 更新 |
| translate | 翻譯 |
| notification | 通知 |
| memory | 記憶體 |
| Settings › Privacy | 「設定 › 隱私權」 |
