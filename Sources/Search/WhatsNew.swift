import SwiftUI

// What's new, once, after an update.
//
// New features start off, so someone who never opens Settings never meets
// them (a reply on X). The first time a newer version opens, a small card
// shows its new switches, each with a line of what it does and the switch
// itself, and — so nothing gets lost — the switches from earlier versions
// that are still off. Nothing else: few words (Drice). Closed, it
// doesn't come back for that version. Not after a fresh install: the welcome
// is for that. Every version's notes are in Settings › About › What's New…
//
// A release edits `toggles` (its new switches, marked with its version),
// `releases` (that it has a card) and `notes` (what it brought).
//
// A few switches lead: first on every card, above that version's own, for
// as long as they are off. Sync with iCloud and Handoff do, since 22 Nov
// 2026: on for a new install (SyncDefault.swift), offered here to everyone
// who had Search before and never turned them on.

enum WhatsNew {
    /// A switch the card offers: the same setting as in Settings.
    struct Toggle {
        let title: String
        let detail: String
        /// The version it came in.
        let since: String
        let get: @MainActor (Preferences) -> Bool
        let set: @MainActor (Preferences, Bool) -> Void
        /// Whether it can do anything now: a switch that needs another one
        /// on stays off the card until it is.
        var shown: @MainActor (Preferences) -> Bool = { _ in true }
        /// First on every card while it is off, whatever its version.
        var lead = false
    }

    /// A version that has a card.
    struct Release {
        let version: String
    }

    /// Every switch worth meeting, the leading ones first, then oldest
    /// last. The card shows the leading ones still off, this version's, and
    /// the older ones still off.
    static let toggles: [Toggle] = [
        // Leading, in this order (see the top of this file).
        Toggle(title: String(localized: "Sync with iCloud"), detail: String(localized: "Your tabs, pins and spaces on your iPhone and your other Macs, end-to-end encrypted."),
               since: "1.0.16", get: { _ in ICloudSync.shared.on },
               set: { _, on in on ? ICloudSync.shared.turnOnOrWait() : ICloudSync.shared.turnOff() },
               // Never beside the folder sync: the two would undo each other.
               shown: { _ in ICloudSync.shared.on || !Sync.shared.on }, lead: true),
        Toggle(title: String(localized: "Handoff to your iPhone"), detail: String(localized: "The page in front comes up in your iPhone's and iPad's app switcher."),
               since: "1.0.16", get: { $0.handoff }, set: { $0.handoff = $1 }, lead: true),
    ] + (AI.shipped ? [
        Toggle(title: String(localized: "AI on pages"), detail: String(localized: "Summarize a page or ask about it. Choose where it runs in Settings › AI."),
               since: "1.0.5", get: { $0.ai }, set: { $0.ai = $1 }),
    ] : []) + [
        Toggle(title: String(localized: "Sidebar button"), detail: String(localized: "Beside the window's buttons, it hides the sidebar as ⌘S does."),
               since: "1.0.18", get: { $0.foldButton }, set: { $0.foldButton = $1 }),
        Toggle(title: String(localized: "Narrow to icons"), detail: String(localized: "Pull the sidebar narrower and it becomes a strip of site icons."),
               since: "1.0.18", get: { $0.narrowsToIcons }, set: { $0.narrowsToIcons = $1 }),

        Toggle(title: String(localized: "Swipe back closes a link's tab"), detail: String(localized: "On the page a link opened, a swipe back closes the tab and takes you to the one you were on."),
               since: "1.0.17", get: { $0.swipeBackCloses }, set: { $0.swipeBackCloses = $1 }),

        Toggle(title: String(localized: "⌘T finds your open tabs"), detail: String(localized: "As you type in ⌘T's field, a matching open tab or pin comes first."),
               since: "1.0.17", get: { $0.arcTabPopup }, set: { $0.arcTabPopup = $1 },
               shown: { $0.floatingNewTab }),
        Toggle(title: String(localized: "Home bookmarks on a new tab"), detail: String(localized: "The sites of your bookmark folder called Home, as tiles."),
               since: "1.0.17", get: { $0.homeGrid }, set: { $0.homeGrid = $1 }),
        Toggle(title: String(localized: "One button per space"), detail: String(localized: "Every space beside the bookmarks, one click away."),
               since: "1.0.17", get: { $0.spaceButtons }, set: { $0.spaceButtons = $1 },
               shown: { $0.usesSpaces }),
        Toggle(title: String(localized: "Try HTTPS first"), detail: String(localized: "An http:// page loads over HTTPS where the site has it."),
               since: "1.0.17", get: { $0.triesHTTPSFirst }, set: { $0.triesHTTPSFirst = $1 }),

        Toggle(title: String(localized: "Always show the address bar"), detail: String(localized: "The page's full address stays in sight, to type in."),
               since: "1.0.16", get: { $0.addressLine }, set: { $0.addressLine = $1 }),
        Toggle(title: String(localized: "Glass window"), detail: String(localized: "The column and the window's edge as frosted glass over your desktop."),
               since: "1.0.16", get: { $0.glass }, set: { $0.glass = $1 }),
        Toggle(title: String(localized: "Buttons at the top"), detail: String(localized: "The column's bottom buttons beside back, forward and reload."),
               since: "1.0.16", get: { $0.doorsUp }, set: { $0.doorsUp = $1 }),
        Toggle(title: String(localized: "Ask which space a link opens in"), detail: String(localized: "For links from other apps."),
               since: "1.0.16", get: { $0.asksSpaceForLinks }, set: { $0.asksSpaceForLinks = $1 }),
        Toggle(title: String(localized: "Dim sleeping tabs"), detail: String(localized: "A tab put to sleep fades until you come back to it."),
               since: "1.0.16", get: { $0.dimsSleepingTabs }, set: { $0.dimsSleepingTabs = $1 }),
        Toggle(title: String(localized: "High contrast tab text"), detail: String(localized: "Tab titles in full black or white."),
               since: "1.0.16", get: { $0.highContrastText }, set: { $0.highContrastText = $1 }),

        Toggle(title: String(localized: "⌘1–⌘9 switch spaces"), detail: String(localized: "As in Arc: the tabs move to ⌃1–⌃9."),
               since: "1.0.15", get: { $0.spacesOnCommand }, set: { $0.spacesOnCommand = $1 },
               shown: { $0.usesSpaces }),
        Toggle(title: String(localized: "Same tabs in every window"), detail: String(localized: "Every window lists the same open tabs, as Arc's sidebar does."),
               since: "1.0.15", get: { $0.mirrorsTabs }, set: { $0.mirrorsTabs = $1 }),
        Toggle(title: String(localized: "⌥-click a link opens it in Split View"), detail: String(localized: "Beside the page you're reading."),
               since: "1.0.15", get: { $0.optionClickSplits }, set: { $0.optionClickSplits = $1 }),
        Toggle(title: String(localized: "Bounce at the top and bottom"), detail: String(localized: "Pages stretch past their ends and spring back, as in Safari."),
               since: "1.0.15", get: { $0.bounces }, set: { $0.bounces = $1 }),
        Toggle(title: String(localized: "Slide the column in and out"), detail: String(localized: "An eased slide for ⌘S and the column that hides."),
               since: "1.0.15", get: { $0.slidesColumn }, set: { $0.slidesColumn = $1 }),

        Toggle(title: String(localized: "Your own style for a site"), detail: String(localized: "Edit Site Style… in the View menu: your CSS for the site you're on, as Arc's Boosts."),
               since: "1.0.14", get: { $0.sitesStyles }, set: { $0.sitesStyles = $1 }),
        Toggle(title: String(localized: "Keep the card in full screen"), detail: String(localized: "The page keeps its room and rounded corners when the window fills the screen."),
               since: "1.0.14", get: { $0.cardsInFullScreen }, set: { $0.cardsInFullScreen = $1 },
               shown: { $0.sidebar && $0.cards }),
        Toggle(title: String(localized: "⌘-click on a pin opens a new tab"), detail: String(localized: "As in Arc, or takes a page that wandered off into the loose tabs."),
               since: "1.0.14", get: { $0.pinCommandOpensTab }, set: { $0.pinCommandOpensTab = $1 }),

        Toggle(title: String(localized: "Commands in the address field"), detail: String(localized: "Type the name of any menu command or setting, as in Arc's Command Bar."),
               since: "1.0.13", get: { $0.commandBar }, set: { $0.commandBar = $1 }),
        Toggle(title: String(localized: "Capture"), detail: String(localized: "View › Capture… takes a picture of part of a page, or all of it."),
               since: "1.0.13", get: { $0.capturesPages }, set: { $0.capturesPages = $1 }),
        Toggle(title: String(localized: "Folders in pinned rows"), detail: String(localized: "Pinned rows in folders that fold, as in Arc."),
               since: "1.0.13", get: { $0.pinFolders }, set: { $0.pinFolders = $1 },
               shown: { $0.listsPins }),

        Toggle(title: String(localized: "Send links to a space"), detail: String(localized: "Links to the sites you choose open in their space, with its sign-ins, as in Arc."),
               since: "1.0.11", get: { $0.sendsLinksToSpaces }, set: { $0.sendsLinksToSpaces = $1 },
               shown: { $0.usesSpaces }),

        Toggle(title: String(localized: "Profiles in one window"), detail: String(localized: "A space of another profile opens in the same window, with that profile's sign-ins, as in Arc."),
               since: "1.0.9", get: { $0.profilesInOneWindow }, set: { $0.profilesInOneWindow = $1 }),

        Toggle(title: String(localized: "Close goes back"), detail: String(localized: "Closing the tab you're on takes you to the one you were on before it, as ⌃Tab would."),
               since: "1.0.8", get: { $0.closeGoesBack }, set: { $0.closeGoesBack = $1 }),

        Toggle(title: String(localized: "Your Apple passwords"), detail: String(localized: "Accounts from Apple's Passwords app under the sign-in field, with a code from your Mac."),
               since: "1.0.7", get: { $0.applePasswords }, set: { $0.applePasswords = $1 }),
        Toggle(title: String(localized: "Ask before quitting"), detail: String(localized: "⌘Q asks first, so a slip doesn't close every window."),
               since: "1.0.7", get: { $0.confirmsQuit }, set: { $0.confirmsQuit = $1 }),
        Toggle(title: String(localized: "Tab numbers while ⌘ is held"), detail: String(localized: "See which tab ⌘1–⌘9 goes to."),
               since: "1.0.7", get: { $0.showsTabShortcuts }, set: { $0.showsTabShortcuts = $1 }),
        Toggle(title: String(localized: "A column of icons only"), detail: String(localized: "The tabs as icons down the side, nothing that grows under the pointer."),
               since: "1.0.7", get: { $0.sideIcons }, set: { $0.sideIcons = $1 }),
        Toggle(title: String(localized: "Escape twice to leave full screen"), detail: String(localized: "One Escape stays with the page, a second leaves full screen."),
               since: "1.0.7", get: { $0.escapeTwice }, set: { $0.escapeTwice = $1 }),

        Toggle(title: String(localized: "Suggestions from your search engine"), detail: String(localized: "Searches suggested as you type. What you type is sent to your engine; never from a private tab."),
               since: "1.0.6", get: { $0.engineSuggests }, set: { $0.engineSuggests = $1 }),
        Toggle(title: String(localized: "Pins keep their site"), detail: String(localized: "Links elsewhere open in a peek, and ⌘W takes a pin back to its page, as in Arc."),
               since: "1.0.6", get: { $0.pinsKeepSite }, set: { $0.pinsKeepSite = $1 }),
        Toggle(title: String(localized: "Darken light pages"), detail: String(localized: "While Search is dark, pages with no dark look of their own are darkened."),
               since: "1.0.6", get: { $0.darkensPages }, set: { $0.darkensPages = $1 }),
        Toggle(title: String(localized: "Roomier tabs"), detail: String(localized: "Taller rows and larger titles in the sidebar."),
               since: "1.0.6", get: { $0.roomyTabs }, set: { $0.roomyTabs = $1 }),
        Toggle(title: String(localized: "New tab in a floating field"), detail: String(localized: "⌘T raises the address field over the page you are on, as in Arc."),
               since: "1.0.6", get: { $0.floatingNewTab }, set: { $0.floatingNewTab = $1 }),

        Toggle(title: String(localized: "Pinned rows"), detail: String(localized: "Pins as rows with their names, under the squares, as in Arc. Right-click a tab to pin it as a row."),
               since: "1.0.5", get: { $0.listsPins }, set: { $0.listsPins = $1 }),
        Toggle(title: String(localized: "Start with a fresh window"), detail: String(localized: "Your pinned tabs, tab groups and named tabs, and none of last time's others."),
               since: "1.0.5", get: { $0.startsFresh }, set: { $0.startsFresh = $1 }),

        Toggle(title: String(localized: "Sidebar on the right"), detail: String(localized: "The tabs down the right edge of the window."),
               since: "1.0.4", get: { $0.sidebar && $0.sidePosition == .right },
               set: { prefs, on in
                   if on { prefs.sidebar = true }
                   prefs.sidePosition = on ? .right : .left
               }),
        Toggle(title: String(localized: "Videos wait for a click"), detail: String(localized: "Videos don't start by themselves, even without sound."),
               since: "1.0.4", get: { $0.waitsForPlay }, set: { $0.waitsForPlay = $1 }),
        Toggle(title: String(localized: "Always show the downloads button"), detail: String(localized: "Your downloads one click away, beside the other buttons."),
               since: "1.0.4", get: { $0.alwaysShowsDownloads }, set: { $0.alwaysShowsDownloads = $1 }),

        Toggle(title: String(localized: "Spaces"), detail: String(localized: "Separate sets of tabs, each with its own sign-ins. ⌃1–⌃9 to switch."),
               since: "1.0.1", get: { $0.usesSpaces }, set: { $0.usesSpaces = $1 }),
        Toggle(title: String(localized: "A sidebar that hides"), detail: String(localized: "The page takes the whole window; the tabs come out at the edge."),
               since: "1.0.1", get: { $0.sidebar && $0.sideHides },
               set: { prefs, on in
                   if on { prefs.sidebar = true }
                   prefs.sideHides = on
               }),
        Toggle(title: String(localized: "Bookmarks bar"), detail: String(localized: "Your bookmarks in a row above the page."),
               since: "1.0.2", get: { $0.bookmarksBar }, set: { $0.bookmarksBar = $1 }),
        Toggle(title: String(localized: "Float the video when you switch apps"), detail: String(localized: "A playing video follows you out into a small window."),
               since: "1.0.2", get: { $0.floatsAway }, set: { prefs, on in if on { prefs.floatOwn = .tabsOrApps } else { prefs.floatsAway = false } }),
        Toggle(title: String(localized: "Pages at 120 Hz"), detail: String(localized: "Smoother scrolling and animations on screens that can. Uses more battery."),
               since: "1.0.2", get: { $0.fastPages != .never }, set: { $0.fastPages = $1 ? .onPower : .never }),
        Toggle(title: String(localized: "Scroll with the middle button"), detail: String(localized: "Click the wheel, then move the mouse to scroll, as on Windows."),
               since: "1.0.3", get: { $0.autoScroll }, set: { $0.autoScroll = $1 }),
    ]

    static let releases: [Release] = [
        Release(version: "1.0.18"),
        Release(version: "1.0.17"),
        Release(version: "1.0.16"),
        Release(version: "1.0.15"),
        Release(version: "1.0.14"),
        Release(version: "1.0.13"),
        Release(version: "1.0.12"),
        Release(version: "1.0.11"),
        Release(version: "1.0.10"),
        Release(version: "1.0.9"),
        Release(version: "1.0.8"),
        Release(version: "1.0.7"),
        Release(version: "1.0.6"),
        Release(version: "1.0.5"),
        Release(version: "1.0.4"),
    ]

    /// What a card opened now lists: first the leading switches still off,
    /// then the version's own; under their caption, the earlier ones still
    /// off.
    @MainActor static func rows(for release: Release, prefs: Preferences) -> (leading: [Toggle], own: [Toggle], earlier: [Toggle]) {
        (toggles.filter { $0.lead && !$0.get(prefs) && $0.shown(prefs) },
         toggles.filter { !$0.lead && $0.since == release.version && $0.shown(prefs) },
         toggles.filter { !$0.lead && older($0.since, than: release.version) && !$0.get(prefs) && $0.shown(prefs) })
    }

    /// This version's card, when it has one.
    static var current: Release? { releases.first { $0.version == Updater.version } }

    /// Version strings in order: 1.0.10 after 1.0.9.
    static func older(_ one: String, than other: String) -> Bool {
        let a = one.split(separator: ".").compactMap { Int($0) }
        let b = other.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(a.count, b.count) {
            let x = i < a.count ? a[i] : 0, y = i < b.count ? b[i] : 0
            if x != y { return x < y }
        }
        return false
    }

    private static let seenKey = "whatsnew.seen"

    /// At launch, once: whether the card is due. Not on a fresh install (the
    /// welcome is up, and this version counts as seen), nor in a test world
    /// unless the bench asks; otherwise once per version that has a card.
    @MainActor static func due(prefs: Preferences, welcoming: Bool) -> Bool {
        let store = Store.settings
        guard let current, !Store.testing else { return false }
        if welcoming {
            store.set(current.version, forKey: seenKey)
            return false
        }
        guard store.string(forKey: seenKey) != current.version else { return false }
        store.set(current.version, forKey: seenKey)
        return true
    }

    // MARK: - every version's notes

    /// What a version brought, for Settings › About › What's New…
    struct Notes {
        let version: String
        let date: String
        /// A sentence or two: what the version is about.
        let headline: String
        let new: [String]
        let better: [String]
        let fixed: [String]
    }

    /// Newest first.
    static let notes: [Notes] = [
        Notes(
            version: "1.0.18", date: String(localized: "22 November 2026"),
            headline: String(localized: "Sync on from the start, news by email, and your fixes."),
            new: [
                String(localized: "Sync with iCloud and Handoff are on for a new install, with both switches on the welcome's first page."),
                String(localized: "News by email and the Search for iPhone beta: leave your email on this card, in the welcome or in Settings › About."),
                String(localized: "A sidebar button beside the window's buttons, and a sidebar that narrows to icons. Settings › Appearance › Tabs."),
            ],
            better: [
                String(localized: "⌘S is smooth again with several spaces and the column made icons only."),
                String(localized: "With the tabs across the top, an open group shows where it starts and ends."),
                String(localized: "Buttons say the key you set for them in Settings › Shortcuts."),
            ],
            fixed: [
                String(localized: "In full screen, the menu bar no longer comes down over the tabs."),
                String(localized: "Selecting text in a field at the very top of a page, and Rename on a pinned square."),
                String(localized: "Asking to save a password nobody typed, and YouTube previews floating as a video."),
                String(localized: "Windows coming back twice, sites at .local names, and tabs showing a lone \u{2026}."),
            ]
        ),
        Notes(
            version: "1.0.17", date: String(localized: "22 November 2026"),
            headline: String(localized: "Spaces from Zen, more browsers to come from, and your fixes."),
            new: [
                String(localized: "Coming from Zen brings its spaces, pins and folders, and open tabs come over from Firefox and Zen."),
                String(localized: "Eleven more browsers to come from, and Safari directly when macOS allows it."),
                String(localized: "Themes for the blank tab, your Home bookmarks as tiles, and ⌘T finding your open tabs. Settings › Themes and Settings › Tabs."),
                String(localized: "A split pinned as a split, one button per space, and Try HTTPS first. Settings › Spaces & Pins and Settings › Privacy."),
            ],
            better: [
                String(localized: "⌘S slides the column smoothly again, as in 1.0.15."),
                String(localized: "Any space can be deleted, the first one included, and profiles can be put in any order."),
                String(localized: "A bookmarks folder of thousands opens at once."),
            ],
            fixed: [
                String(localized: "Pinned-row folders syncing between Macs, and the history of signed-out spaces."),
                String(localized: "YouTube videos held at 0:00, YouTube Music's floating player, and Reddit's promoted posts."),
                String(localized: "Client certificates for company sign-ins, security keys with passkeys off, and games locking the pointer."),
                String(localized: "Stylus, Monarch Money, Floccus, Similarweb and Brandsearch."),
            ]
        ),
        Notes(
            version: "1.0.16", date: String(localized: "20 November 2026"),
            headline: String(localized: "Sync with your iPhone, Handoff, and two days of your fixes."),
            new: [
                String(localized: "Sync with iCloud: open tabs, pins, spaces and bookmarks with Search on iPhone, in public beta. Settings › General."),
                String(localized: "Handoff of the page in front to your iPhone and iPad. Settings › General."),
                String(localized: "The address bar always in sight, a glass window, and buttons at the top. Settings › Appearance."),
                String(localized: "Choose the space a link from another app opens in. Settings › Spaces & Pins."),
            ],
            better: [
                String(localized: "Switching spaces is about three times quicker with many tabs."),
                String(localized: "The accounts under a sign-in box answer ↓, ↑ and Return."),
                String(localized: "A sideways scroll in Google Sheets scrolls the sheet instead of going back."),
            ],
            fixed: [
                String(localized: "Swish and other window managers moving the window, and ⌃⌘F."),
                String(localized: "Teams' Shared tab, PDFs that stopped zooming, and Zotero Connector."),
                String(localized: "⌘S forgetting the hidden column, and spelling corrected with correction off."),
                String(localized: "A crash on macOS 27.2."),
            ]
        ),
        Notes(
            version: "1.0.15", date: String(localized: "18 November 2026"),
            headline: String(localized: "Space gradients, extensions that work, coding agents, and a day of your fixes."),
            new: [
                String(localized: "A gradient or a stronger colour for a space. The space's menu › Colour…."),
                String(localized: "The same tabs in every window. Settings › Tabs."),
                String(localized: "⌘1–⌘9 switch spaces, as in Arc. Settings › Spaces & Pins."),
                String(localized: "Email links open in Gmail, Outlook.com, Fastmail or Proton Mail. Settings › General."),
                String(localized: "Choose where each extension runs: all sites, some, or on click. Settings › Extensions."),
                String(localized: "Claude Code or Codex can browse in tabs of their own while you watch. Settings › About › Developer."),
            ],
            better: [
                String(localized: "Pages load faster with extensions on."),
                String(localized: "Spread two fingers on a peek to open it as a tab."),
                String(localized: "A right-click anywhere in the tab column has a menu."),
            ],
            fixed: [
                String(localized: "Eagle, Cosmos, Raindrop.io, Language Reactor and Voice-over-Translation."),
                String(localized: "Signing in to X with passkeys off, and 1Password passkeys."),
                String(localized: "Claude's side panel once signed in."),
                String(localized: "Extensions reopening their welcome tab at every launch."),
            ]
        ),
        Notes(
            version: "1.0.14", date: String(localized: "17 November 2026"),
            headline: String(localized: "Live folders, your own style for a site, space colours on the window, and your fixes."),
            new: [
                String(localized: "Live folders: a folder in the pinned rows that fills itself from a feed. Right-click a pinned row › New Live Folder…."),
                String(localized: "Your own CSS for a site, as Arc's Boosts. Turn it on in Settings › Browsing."),
                String(localized: "Keep the page as a card in full screen. Settings › Appearance › Window."),
                String(localized: "⌘-click on a pin opens a new tab, as in Arc. Settings › Spaces & Pins."),
            ],
            better: [
                String(localized: "A space with a colour gives the window a faint wash of it."),
            ],
            fixed: [
                String(localized: "⌘1–⌘9 counting a group's closed tabs."),
                String(localized: "⌫ leaving the page you were typing in."),
                String(localized: "Extension popups that open themselves, such as Inoreader's."),
            ]
        ),
        Notes(
            version: "1.0.13", date: String(localized: "17 November 2026"),
            headline: String(localized: "Folders in pinned rows, Split View with four pages, sync between your Macs, and your fixes."),
            new: [
                String(localized: "Sync your spaces, pins, bookmarks and a few settings between your Macs, through a folder they share. Settings › General."),
                String(localized: "Folders in pinned rows, as in Arc. Settings › Spaces & Pins."),
                String(localized: "Capture… in the View menu: a picture of part of a page, or all of it."),
                String(localized: "Commands in the address field, as Arc's Command Bar."),
                String(localized: "History › Archived Tabs: the tabs Search closed by itself, for 30 days."),
                String(localized: "A colour for each space, from the space's menu."),
                String(localized: "The address field from any app, with a key of your own. Settings › Keyboard & Mouse."),
            ],
            better: [
                String(localized: "Split View holds up to four pages."),
                String(localized: "Switching tabs shows the page sooner."),
                String(localized: "A new install starts with the tabs down the side, and links from other apps in a small window."),
            ],
            fixed: [
                String(localized: "⌘T opening its page in a group, from an empty tab left there."),
                String(localized: "A window opened with ⌘N that the menus didn't act on."),
                String(localized: "Control Panel for YouTube not saving its switches."),
                String(localized: "The floating video coming back small in its tab."),
                String(localized: "A link from another app bringing up the browser's window beside its small one."),
            ]
        ),
        Notes(
            version: "1.0.12", date: String(localized: "9 November 2026"),
            headline: String(localized: "Your contact details in forms, a tab dragged across the top again, and your fixes."),
            new: [
                String(localized: "Your card in Contacts under a box for your name, email, phone or address, as in Safari. Turn it on in Settings › Passwords."),
                String(localized: "Open All in New Tabs at the foot of each folder in the Bookmarks menu."),
            ],
            better: [
                String(localized: "A tab carried off its row or column goes with the pointer."),
                String(localized: "Pages with many frames load quicker with extensions such as 1Password."),
            ],
            fixed: [
                String(localized: "A tab across the top that couldn't be dragged, moving the window instead, with Tabs give when pressed on."),
            ]
        ),
        Notes(
            version: "1.0.11", date: String(localized: "9 November 2026"),
            headline: String(localized: "Send links to a space, a proxy for the whole browser, a quicker window with many tabs, and your fixes."),
            new: [
                String(localized: "Send links to a space, as in Arc: the sites you choose open in their space, in Settings › Spaces & Pins or a tab's right-click menu."),
                String(localized: "An HTTP or SOCKS5 proxy for the whole browser, in Settings › Privacy."),
                String(localized: "Bring Things Over can bring the tabs Helium, Chrome or another Chromium browser has open, with their groups."),
                String(localized: "⌥-click a tab to put it beside the page in Split View."),
                String(localized: "Replace a pin's page with the one it shows, from the pin's right-click menu."),
            ],
            better: [
                String(localized: "Typing in the address field and swiping between spaces stay quick with many tabs open."),
                String(localized: "Your site shortcuts are offered as you type, like the built-in sites."),
                String(localized: "The tab column has no scroll bar, as the tabs across the top."),
                String(localized: "Show how far you've read is off unless you turn it on."),
                String(localized: "Passkeys and saved passwords are handled more carefully, and the sites you sign in to stay out of the Mac's log."),
            ],
            fixed: [
                String(localized: "⌘-click opening a link in the same tab on some shops."),
                String(localized: "The floating video flickering as it pops out of the page."),
                String(localized: "Closing a window right after using it taking away its space's pins."),
                String(localized: "And more, from your messages and pull requests."),
            ]
        ),
        Notes(
            version: "1.0.10", date: String(localized: "8 November 2026"),
            headline: String(localized: "Site permissions in the site card, Claude in Chrome can act in Search, ⇧⌘T brings tabs back as they were, and your fixes."),
            new: [
                String(localized: "Site Permissions in the site card: camera, microphone, location and notifications, each Ask, Allow or Block."),
                String(localized: "Codes from Apple's Passwords app under the box that asks for one."),
                String(localized: "Choose the language pages are translated into, in Settings › Browsing."),
                String(localized: "Shift-Return searches with a second engine, if you pick one in Settings › Browsing."),
                String(localized: "Copy Address in a download's right-click menu."),
                String(localized: "With a site put in the address field with Tab, what you searched there before, read from this Mac only."),
            ],
            better: [
                String(localized: "The address field says where Return goes, and the key that raised it puts it away."),
                String(localized: "⇧⌘T brings a tab back with its Back and Forward, and brings back Settings, History and the other pages of Search."),
                String(localized: "Turning the blocker off for one site is a switch in the site's card."),
                String(localized: "With Tabs show: Letters, a tab's letter is beside its title."),
                String(localized: "⌘S slides the column at once, and keeping a bookmark no longer stalls a window with many tabs."),
                String(localized: "Dragging one of several selected tabs carries them all."),
                String(localized: "A space's downloads folder is one Downloads submenu in its menu."),
            ],
            fixed: [
                String(localized: "Claude in Chrome's actions, which all failed with \"No tabs to group\"."),
                String(localized: "Discord signing you out when reloaded with the column out."),
                String(localized: "A video on a TV or second display floating out when you work in another app on this screen."),
                String(localized: "A tab carried past another or a Split View pair drifting away from the pointer."),
                String(localized: "A closed tab's video or music playing on in the background."),
                String(localized: "uBlock Origin Lite leaving GitLab and similar pages half-drawn."),
                String(localized: "A waking tab shown zoomed in, and a window stuck after a video's full screen."),
                String(localized: "And many more, most from your messages and pull requests."),
            ]
        ),
        Notes(
            version: "1.0.9", date: String(localized: "4 November 2026"),
            headline: String(localized: "Claude in the side panel, profiles in one window, and your fixes."),
            new: [
                String(localized: "Profiles in one window, as in Arc, if you turn it on in Settings › Spaces & Pins."),
                String(localized: "Downloads can open floating by its button, or in the side panel."),
                String(localized: "Delete in a pin's right-click menu."),
            ],
            better: [
                String(localized: "Claude in Chrome's side panel is signed in when your tabs are."),
                String(localized: "Address suggestions match words anywhere in a page's title and forgive typos."),
                String(localized: "⌘R reloads the page in a peek, and a link's menu starts with Open Link in New Tab."),
                String(localized: "A video floats when you switch spaces, if automatic floating is on."),
            ],
            fixed: [
                String(localized: "Copy Image copies at once, where a big picture took up to a minute."),
                String(localized: "Google Docs and Sheets are sharp on macOS 26.3 and earlier."),
                String(localized: "A pin no longer stays stuck mid-drag, and a page no longer stays shifted after a swipe back."),
                String(localized: "A page that keeps crashing stops reloading itself and says so."),
                String(localized: "And many more, most from your messages and pull requests."),
            ]
        ),
        Notes(
            version: "1.0.8", date: String(localized: "2 November 2026"),
            headline: String(localized: "Your fixes, by the dozen, and a few small things."),
            new: [
                String(localized: "Open Link in Split View, in a link's right-click menu."),
                String(localized: "Close Tabs Below, beside Close Other Tabs."),
                String(localized: "File › Save Page As… keeps a page as one web archive."),
                String(localized: "Closing a tab can take you back to the one you were on before, if you turn it on."),
            ],
            better: [
                String(localized: "Bookmarks in the address field as you type, by name or address."),
                String(localized: "Links opened behind a page go after it in the order you clicked them."),
                String(localized: "⌘W closes every tab picked in the column; a tab in a group is put away rather than closed."),
                String(localized: "Closing the last window lets its pages sleep, as Safari and Chrome do."),
            ],
            fixed: [
                String(localized: "Typing in a new tab no longer stops with a beep after the first letters."),
                String(localized: "The page under a peek no longer reacts to the pointer."),
                String(localized: "1Password no longer quits Search on macOS 15; Claude's and ChatGPT's side panels and Vimium C work again."),
                String(localized: "Picture in picture's button takes you back to the video, and a paused full-screen video takes clicks."),
                String(localized: "And many more, most from your messages and pull requests."),
            ]
        ),
        Notes(
            version: "1.0.7", date: String(localized: "25 October 2026"),
            headline: String(localized: "Settings as a page, profiles, page translation, Apple Passwords and YouTube without ads."),
            new: [
                String(localized: "Settings, History, Downloads, Bookmarks and Passwords open as pages in tabs of their own; Settings is sorted into sections with ⌘F to find a setting."),
                String(localized: "Profiles: each keeps its own spaces, sign-ins, history and bookmarks, one per window."),
                String(localized: "Translate a page on your Mac, from its right-click menu; nothing is sent anywhere."),
                String(localized: "Your passwords from Apple's Passwords app, under the sign-in field."),
                String(localized: "Shield blocks YouTube's ads."),
                String(localized: "The tab you're on shows its site; plain http and look-alike names always show."),
                String(localized: "A site in the side panel, a column of icons only, ask before quitting, tab numbers while ⌘ is held."),
                String(localized: "Copy Clean Link, Fold All Groups, Move Group to Space, ⌃Tab on a key of your own, Open 2 Tabs in Split View."),
            ],
            better: [
                String(localized: "Fewer switches: Split View, tab groups and more are simply there; pins keep their site by default."),
                String(localized: "Drag tabs onto the pins and pins back among the tabs; small handles on the edges you resize."),
                String(localized: "A call keeps its camera and sound when you switch tabs."),
                String(localized: "Reading mode keeps pictures and charts and follows light and dark."),
            ],
            fixed: [
                String(localized: "Saved accounts show under the sign-in field again, and only in real sign-in fields."),
                String(localized: "Sites you allow get your location; links to other folders' files open."),
                String(localized: "Norma's and other extensions' block pages show; an extension's rules no longer blank pages."),
                String(localized: "And many more, most from your messages and pull requests."),
            ]
        ),
        Notes(
            version: "1.0.6", date: String(localized: "24 October 2026"),
            headline: String(localized: "A side panel, blocked pop-ups you can open, and a month of your fixes. What's new is off until you turn it on, and the card after the update offers it."),
            new: [
                String(localized: "An extension's side panel, as in Chrome: Claude's, ChatGPT's or Sider's panel opens beside the page instead of in a tab."),
                String(localized: "A pop-up refused because no click asked for it says so beside the tab's title, with Open and Always Allow, as in Safari."),
                String(localized: "Suggestions from your search engine as you type, never from a private tab."),
                String(localized: "Extensions in private tabs, each with its own switch in Settings › Extensions."),
                String(localized: "Pins go back home and keep their site, with links elsewhere in a peek; pins can sit above every space."),
                String(localized: "Tabs can close themselves after a while, and chosen sites can stay awake."),
                String(localized: "⇧⌘W closes the window, the mouse's side buttons change space, and media keys reach the page."),
                String(localized: "New tabs at the top or the bottom, a floating ⌘T, roomier tabs, and light pages darkened in dark mode."),
                String(localized: "Select several tabs with ⌘- or ⇧-click, export a page as a PDF, and Open With from the Finder."),
            ],
            better: [
                String(localized: "The page as a card can be turned off, and full screen goes edge to edge."),
                String(localized: "Leaving a video's full screen happens in one move."),
                String(localized: "Pins in spaces you aren't in sleep and give their memory back."),
                String(localized: "A bookmark opens in a tab of its own, never in a pin's place."),
                String(localized: "Claude in Chrome signs in, and signs in again quietly each time Search starts."),
                String(localized: "Stylus and Vimium C work."),
            ],
            fixed: [
                String(localized: "A pop-up rewritten by the page that opened it is no longer offered that site's saved passwords."),
                String(localized: "Sites you allow to know your location get it."),
                String(localized: "Start with a fresh window keeps your tab groups and named tabs."),
                String(localized: "A Gmail link opens one tab, not two."),
                String(localized: "A video file opened as a page plays."),
                String(localized: "Links between files on your Mac open, and links in AI chats' answers too."),
                String(localized: "Saved accounts show with Split View on."),
                String(localized: "Dragging a tab across the top moves the tab, not the window."),
                String(localized: "And many more, most from your messages and pull requests."),
            ]
        ),
        Notes(
            version: "1.0.5", date: String(localized: "14 October 2026"),
            headline: String(localized: "Split View, pinned rows, notifications and screen recorders. What's new is off until you turn it on, and the card after the update offers it."),
            new: [
                String(localized: "With the tabs down the side, the page sits in the window as a card, a little apart from the column."),
                String(localized: "Split View: two tabs side by side. Drag a tab to the left or right edge of a page, choose Open in Split View in its menu, or press ⌥⌘N."),
                String(localized: "Pinned rows, as in Arc: a pin can be a row with its name, under the squares, and Clear closes the tabs below."),
                String(localized: "Websites can send notifications and ask for your location, as in Safari, site by site."),
                String(localized: "Loom and other screen recorders work: macOS asks what to share each time, and a pill says who is recording, with Stop."),
                String(localized: "Search a site straight from the address field, as in Arc: type its name, then Tab."),
                String(localized: "Passkeys show under the sign-in field, beside your saved passwords."),
                String(localized: "Sign-ins that ask for your name first, or for a password alone, offer your saved accounts too."),
                String(localized: "Your Mac's text replacements work in pages, and Edit › Substitutions turns them, smart quotes and smart dashes on or off."),
                String(localized: "Find says “3 of 17”, paints every match, and can match case or whole words."),
                String(localized: "Downloads pause and resume."),
                String(localized: "Open Link in New Tab leaves you where you are; hold ⌥ to go to it."),
                String(localized: "Search can start with a fresh window: your pinned tabs, tab groups and named tabs, and none of last time's others."),
                String(localized: "Intel Macs get a download of their own."),
            ],
            better: [
                String(localized: "Search is built for size, so all of this fits in 6.8 MB, and pages that change all the time, like a chat writing its answer, stay quick."),
                String(localized: "An extension's popup window opens as a small window, as in Chrome: a password manager's vault, a sign-in."),
                String(localized: "Esc closes a new tab you haven't used, and words typed into a new tab wait for you."),
                String(localized: "Tampermonkey installs scripts from a link, and SingleFile saves pages again."),
                String(localized: "Close Group in a tab group's menu, and one ⇧⌘T brings the whole group back."),
                String(localized: "Don't Float Videos Here, in a site's card."),
                String(localized: "Bringing Arc over keeps its shape: pinned pages as pinned rows, its folders as named tab groups."),
                String(localized: "Too many pinned extensions no longer push the column off screen."),
                String(localized: "Empty a bookmark's name and it is its icon alone on the bookmarks bar."),
            ],
            fixed: [
                String(localized: "A live video, on X and elsewhere, no longer jumps every few seconds."),
                String(localized: "A site's icon follows the page: GitHub's in the dark, a chat's unread count, and each port of localhost its own."),
                String(localized: "Pins brought over from Arc wear their icons straight away."),
                String(localized: "The tabs come back after a video's full screen."),
                String(localized: "A folder in the bookmarks list opens whole."),
                String(localized: "Signing in with a passkey works on GitHub again."),
                String(localized: "Bitwarden's passkey window, its sync and its narrow popup."),
                String(localized: "Keys in games no longer make the Mac beep."),
                String(localized: "History keeps localhost:3000 and localhost:4000 apart."),
                String(localized: "Copy Image works on WhatsApp Web's photos."),
                String(localized: "Signing in to Claude's extension finishes on claude.ai."),
                String(localized: "The Bookmarks menu keeps its bookmarks while a tab's title keeps changing."),
                String(localized: "Popovers keep their rounded corners on macOS 15."),
                String(localized: "Security hardening from a third careful private report, and many smaller fixes."),
            ]
        ),
        Notes(
            version: "1.0.4", date: String(localized: "27 September 2026"),
            headline: String(localized: "Several windows, and a lot to discover. Most of what's new is off until you turn it on, and the card after the update offers it."),
            new: [
                String(localized: "Several windows. ⌘N opens one with its own tabs; drag a tab out of the row, or use Move to Window in its menu, and it moves with its page as it is. Pinned tabs are the same in every window."),
                String(localized: "Tab groups, and a sidebar on the right."),
                String(localized: "⌃Tab shows your recent tabs as pictures, the last one first: a quick ⌃Tab goes back to the tab you were on."),
                String(localized: "Your own keyboard shortcuts, in Settings › Shortcuts."),
                String(localized: "Downloads show while they happen: a small circle fills beside the other buttons, and the Finder and the Dock show the progress too. The button can stay there for good."),
                String(localized: "Bring things over from Firefox, Zen, Helium, Comet, Opera, Chrome's other channels and Arc, its spaces and pinned tabs included, or from an exported file."),
                String(localized: "Site shortcuts: a word of your own before a search sends it to that site, like yt cats to YouTube."),
                String(localized: "Bookmarks in the order you choose, folders of your own, and a card to name a bookmark as you add it."),
                String(localized: "Videos can wait for a click, and every site can start at a zoom of your choice."),
                String(localized: "A double-click on a pinned tab takes it back to the page it was pinned at."),
                String(localized: "Hold a back or forward swipe to pick a page from history."),
            ],
            better: [
                String(localized: "Scrolling asks far less of the window, and a tab still loading no longer keeps the Mac busy."),
                String(localized: "Where links go, peeking at a link with a shift-click, and flicking the floating video to a corner are now on."),
                String(localized: "Tab managers and other extensions see every tab, in every window."),
                String(localized: "Window › Move & Resize and the Mac's tiling work with Search's window."),
                String(localized: "⌘K always opens the list of your tabs, whatever the page."),
            ],
            fixed: [
                String(localized: "⌘← and ⌘→ go back and forward again."),
                String(localized: "Links from Notion and other apps bring Search to the front."),
                String(localized: "Addresses a dev server prints, like 0.0.0.0:3000, open."),
                String(localized: "The tabs you had at quit are the ones that come back."),
                String(localized: "The × closes a tab in the tab bar folded away with ⌘S."),
                String(localized: "1Password, Bitwarden, NordPass, Passbolt, iCloud Passwords and the Claude extension each get their fixes."),
                String(localized: "And many smaller fixes."),
            ]
        ),
        Notes(
            version: "1.0.3", date: String(localized: "24 September 2026"),
            headline: String(localized: "Security, and the mouse wheel."),
            new: [
                String(localized: "Copying a saved password asks for Touch ID."),
            ],
            better: [
                String(localized: "A mouse wheel scrolls smoothly again on x.com and pages like it."),
                String(localized: "History opens at once."),
                String(localized: "Music keeps playing when you switch spaces."),
                String(localized: "Pop-ups need a click."),
            ],
            fixed: [
                String(localized: "The holes found in this week's reviews: an extension could read files outside its own folder, and a page or an ad could open another app without asking."),
                String(localized: "Bitwarden signs in to a self-hosted server, and extension popups hear what changes while they're open."),
                String(localized: "A link from Mail brings Search to the front, and a full-screen video no longer goes black."),
                String(localized: "Your extensions may each ask once more for their permissions at their next update."),
            ]
        ),
        Notes(
            version: "1.0.2", date: String(localized: "24 September 2026"),
            headline: String(localized: "Passkeys, password managers and Google."),
            new: [
                String(localized: "A site's passkey button brings up the Mac's own passkey sheet: Touch ID, your iPhone, a security key."),
                String(localized: "Search can be the Mac's default browser."),
                String(localized: "Each off until you turn it on in Settings: a bookmarks bar, a peek at a link with a shift-click, the video that follows you to another app, pages at 120 Hz, and where a link goes."),
                String(localized: "Mute a tab, share a page, copy a link as Markdown, the mouse's back and forward buttons, and spaces in the bar across the top."),
            ],
            better: [
                String(localized: "Faster to open, and new tabs in about 10 ms."),
                String(localized: "Pages see nothing of Search that Safari doesn't show them, and a saved password is offered only on its own site."),
            ],
            fixed: [
                String(localized: "1Password, Bitwarden and Proton Pass."),
                String(localized: "If passkeys still fail after the update, restart your Mac once."),
            ]
        ),
        Notes(
            version: "1.0.1", date: String(localized: "23 September 2026"),
            headline: String(localized: "The first update, made of a day of your replies and pull requests."),
            new: [
                String(localized: "Each off until you turn it on in Settings: Spaces, a sidebar that hides until the pointer reaches the edge, and the search engine of your choice."),
                String(localized: "⌘S folds the sidebar away, a middle-click closes a tab, a tab can be renamed, and the Web Inspector is in the View menu."),
            ],
            better: [],
            fixed: [
                String(localized: "Search opens again on macOS 14."),
                String(localized: "Signing in to Google no longer reloads the page over and over with iCloud Passwords installed."),
                String(localized: "⌘1–⌘9 on every keyboard layout, Tab between a form's fields, dragging tabs, a double-click along the top to fill the screen, and the Mac's beep while typing."),
            ]
        ),
        Notes(
            version: "1.0", date: String(localized: "23 September 2026"),
            headline: String(localized: "The first version. A browser for the Mac with nothing in the way."),
            new: [
                String(localized: "Tabs in a row or down the side, pinned tabs that keep their place, and one field for addresses and searches."),
                String(localized: "Ads blocked before they load; passwords and passkeys in your keychain."),
                String(localized: "Anything on a page can be hidden; articles open in a reading mode and videos float."),
                String(localized: "Chrome extensions from the Chrome Web Store, on macOS 15.4 or later."),
                String(localized: "Tabs you haven't looked at for half an hour sleep and give their memory back."),
                String(localized: "It runs on the engine already in macOS and weighs 2.9 MB."),
            ],
            better: [],
            fixed: []
        ),
    ]
}

/// The card: what's new in this version, its switches right there, and
/// the earlier ones still off.
struct WhatsNewCard: View {
    let release: WhatsNew.Release
    @ObservedObject var prefs: Preferences
    let close: () -> Void
    let notes: () -> Void
    /// A link from the card (the privacy page), opened in a tab.
    var open: (URL) -> Void = { NSWorkspace.shared.open($0) }
    /// For pictures: the email block's state, and whether it is offered
    /// whatever this Mac remembers.
    var optInStart: OptInForm.Phase = .idle
    var optInEmail = ""
    var optInForced: Bool? = nil

    /// The leading and earlier switches, read once as the card opens
    /// (WhatsNew.rows): one turned on here stays in the list rather than
    /// vanishing under the hand. The version's own are read as they stand.
    @State private var listed: (leading: [WhatsNew.Toggle], own: [WhatsNew.Toggle], earlier: [WhatsNew.Toggle])?
    /// Sync with iCloud's switch is its own, not a preference's.
    @ObservedObject private var icloud = ICloudSync.shared
    /// The email block (OptIn.swift), read once as the card opens: offered
    /// until an email has been given, and kept after one is, for its thanks.
    @State private var offering: Bool?
    @ObservedObject private var reach = OptIn.Reach.shared

    /// Pinned under the list, outside its scroll, so it is always in sight;
    /// left off while the Mac is offline, where a press could only fail.
    private var showsOptIn: Bool { (optInForced ?? offering ?? OptIn.offered()) && (optInForced != nil || reach.online) }

    var body: some View {
        Plate(String(localized: "New in Search \(release.version)"), width: 460, close: close) {
            VStack(alignment: .leading, spacing: 14) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        rows((listed?.leading ?? []) + WhatsNew.rows(for: release, prefs: prefs).own)
                        if let earlier = listed?.earlier, !earlier.isEmpty {
                            Caption(String(localized: "From earlier versions, in case you missed them"))
                                .padding(.top, 6)
                            rows(earlier)
                        }
                    }
                }
                .frame(maxHeight: showsOptIn ? 360 : 470)
                .fixedSize(horizontal: false, vertical: true)
                if showsOptIn {
                    OptInBlock(source: .whatsNew, open: open, start: optInStart, startEmail: optInEmail)
                }
            }
        } foot: {
            HStack {
                Button(action: notes) {
                    Text("Everything that's new…")
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.muted)
                }
                .buttonStyle(.plain)
                Spacer()
                Pill(String(localized: "Close"), filled: true, action: close)
            }
        }
        .onAppear {
            if offering == nil { offering = OptIn.offered() }
            if listed == nil { listed = WhatsNew.rows(for: release, prefs: prefs) }
        }
    }

    private func rows(_ toggles: [WhatsNew.Toggle]) -> some View {
        Card {
            ForEach(Array(toggles.enumerated()), id: \.offset) { index, toggle in
                if index > 0 { Rule() }
                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(toggle.title)
                            .font(.system(size: 13))
                            .foregroundStyle(Palette.ink)
                        Text(toggle.detail)
                            .font(.system(size: 11.5))
                            .foregroundStyle(Palette.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    Switch(on: Binding(get: { toggle.get(prefs) }, set: { toggle.set(prefs, $0) }))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
        }
    }
}

/// Every version's notes, newest first: Settings › About › What's New…
struct ReleaseNotesPanel: View {
    let close: () -> Void

    var body: some View {
        Plate(String(localized: "What's New"), width: 560, close: close) {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    ForEach(WhatsNew.notes, id: \.version) { note in
                        version(note)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
            }
            .listHeight(480)
        }
    }

    private func version(_ note: WhatsNew.Notes) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(verbatim: "Search \(note.version)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                if !note.date.isEmpty {
                    Text(note.date)
                        .font(.system(size: 12))
                        .foregroundStyle(Palette.faint)
                }
            }
            Text(note.headline)
                .font(.system(size: 13))
                .foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
            list(String(localized: "New"), note.new)
            list(String(localized: "Better"), note.better)
            list(String(localized: "Fixed"), note.fixed)
        }
    }

    @ViewBuilder
    private func list(_ title: String, _ lines: [String]) -> some View {
        if !lines.isEmpty {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(Palette.muted)
                ForEach(lines, id: \.self) { line in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•").foregroundStyle(Palette.faint)
                        Text(line)
                            .foregroundStyle(Palette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .font(.system(size: 12.5))
                }
            }
        }
    }
}
