#!/usr/bin/env python3
"""Every English string the interface shows, against each language's table.

    python3 Localization/check.py            all languages, missing keys listed
    python3 Localization/check.py FILE...    only the keys found in those files
    python3 Localization/check.py --table T.strings FILE...
                                             against that table instead

It reads the keys the way the app looks them up:

- String(localized: "…"), NSLocalizedString("…", …) and
  Bundle.main.localizedString(forKey: "…", …);
- the first string of the SwiftUI views and modifiers that take a
  LocalizedStringKey: Text("…"), Button("…"), Toggle("…"), Label("…"), …,
  .help("…"), .navigationTitle("…");
- SettingsIndex's titles, details and "more" lines, looked up at run time.

An interpolation, \\(…), stands for any format specifier (%@, %lld, %lf …):
its type isn't in the source, and a key with the wrong one is simply not
found, the English shown. A translation found must carry the same
specifiers as its key, or the app would read the wrong argument.

Keys with no word in them ("⌘K", "·") are left out. Exits 1 when a key is
missing or a translation's specifiers don't match.
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP = {"Bench.swift", "ExtensionShims.swift"}

LITERAL = r'"((?:[^"\\\n]|\\.)*)"'
VIEWS = ("Text|Button|Toggle|Label|Section|Picker|Menu|TextField|SecureField|"
         "LabeledContent|Link|GroupBox|DisclosureGroup|CommandMenu|ShareLink|Stepper|"
         "ControlGroup|ProgressView")
PATTERNS = [
    re.compile(r'String\(localized:\s*' + LITERAL),
    re.compile(r'NSLocalizedString\(\s*' + LITERAL),
    re.compile(r'localizedString\(forKey:\s*' + LITERAL),
    re.compile(r'(?<![\w.])(?:SwiftUI\.)?(?:' + VIEWS + r')\(\s*' + LITERAL),
    re.compile(r'\.(?:help|navigationTitle|accessibilityLabel|accessibilityHint|alert|confirmationDialog)\(\s*' + LITERAL),
]
# SettingsIndex keeps English in its rows and translates them when drawn.
SETTINGS = re.compile(r'\b(?:title|detail|more):\s*' + LITERAL)

SPEC = re.compile(r'%(?:\d+\$)?(?:ll|l|h)?[@dDuUxXoOfFeEgGcCsSp]|%%')


def unescape(s):
    s = re.sub(r'\\u\{([0-9A-Fa-f]+)\}', lambda m: chr(int(m.group(1), 16)), s)
    return s.replace('\\"', '"').replace("\\n", "\n").replace("\\t", "\t").replace("\\\\", "\\")


def interpolations(s):
    """The literal with each \\(…) cut out, balanced parentheses and all."""
    out, i = [], 0
    while i < len(s):
        if s.startswith("\\(", i):
            depth, j = 1, i + 2
            while j < len(s) and depth:
                depth += {"(": 1, ")": -1}.get(s[j], 0)
                j += 1
            out.append("\0")
            i = j
        else:
            out.append(s[i])
            i += 1
    return "".join(out)


def keys_in(path):
    text = open(path, encoding="utf-8").read()
    # Comments say things like Text("…") too.
    text = re.sub(r'//[^\n]*', lambda m: "" if m.group(0).count('"') % 2 == 0 else m.group(0), text)
    found = set()
    patterns = PATTERNS + ([SETTINGS] if os.path.basename(path) == "SettingsIndex.swift" else [])
    for pattern in patterns:
        for m in pattern.finditer(text):
            raw = m.group(1)
            if raw.startswith("verbatim"):
                continue
            key = unescape(interpolations(raw))
            if re.search(r'[A-Za-z]{2}', key.replace("\0", "")):
                found.add(key)
    return found


def read_table(path):
    """A .strings file as {key: value}, comments skipped."""
    text = open(path, encoding="utf-8").read()
    text = re.sub(r'/\*.*?\*/', "", text, flags=re.S)
    table = {}
    for m in re.finditer(r'^\s*' + LITERAL + r'\s*=\s*' + LITERAL + r'\s*;', text, flags=re.M):
        table[unescape(m.group(1))] = unescape(m.group(2))
    return table


def matcher(key):
    # With a value in it the key is a format, and a literal % in the words
    # is written %% (String(localized:) and Text do that themselves).
    parts = [re.escape(p.replace("%", "%%")) for p in key.split("\0")]
    return re.compile("^" + SPEC.pattern.join(["(?:", ")"]).join(parts) + "$") if len(parts) > 1 else None


def specifiers(s):
    return sorted(re.sub(r'\d+\$', "", m) for m in SPEC.findall(s) if m != "%%")


def collect(files):
    """{key: the first file it is in}."""
    keys = {}
    for f in files:
        if os.path.basename(f) in SKIP:
            continue
        for k in keys_in(f):
            keys.setdefault(k, os.path.relpath(f, ROOT))
    return keys


def audit(keys, table_path):
    """Prints what one table lacks or gets wrong; returns how many."""
    lang = os.path.basename(os.path.dirname(table_path)) or table_path
    table = read_table(table_path)
    missing = []
    for key, where in sorted(keys.items(), key=lambda kv: (kv[1], kv[0])):
        m = matcher(key)
        if not any((m.match(k) if m else k == key) for k in table):
            missing.append((where, key.replace("\0", "\\(…)")))
    # The app builds keys with plain %@ and %lld; a key with %1$@ in it is
    # never looked up. Positions belong in the translation only.
    mismatched = [k for k, v in table.items()
                  if specifiers(k) != specifiers(v) or re.search(r'%\d+\$', k)]
    for where, key in missing:
        print(f"{lang}  missing  {where}: {key!r}")
    for k in mismatched:
        print(f"{lang}  specifiers  {k!r} → {table[k]!r}")
    print(f"{lang}: {len(keys) - len(missing)}/{len(keys)} keys translated, "
          f"{len(mismatched)} specifier mismatches, {len(table)} entries")
    return len(missing) + len(mismatched)


def main():
    args = sys.argv[1:]
    tables = sorted(glob.glob(os.path.join(ROOT, "Localization/*.lproj/Localizable.strings")))
    if args[:1] == ["--table"]:
        tables, args = [args[1]], args[2:]
    keys = collect(args or sorted(glob.glob(os.path.join(ROOT, "Sources/Search/*.swift"))))
    bad = sum(audit(keys, t) for t in tables)
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
