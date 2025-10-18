#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Export Thai romanization dictionary to JSON for InputMethodKit
- Converts RTGS to Paiboon romanization (e.g., kin → gin, phom → pom)
- Filters to only common words (those in tnc_freq.txt) for smaller file size
- Sorts candidates by frequency (most common words first)
- NOTE: Vowel variants (sawasdee/sawatdee/sawadee) are now computed at runtime in Swift
"""

import json
import csv
import re
from typing import Dict, List, Set


def load_thai_romanization_data(csv_path: str, max_entries: int = None) -> Dict[str, List[str]]:
    """
    Load Thai to romanization mappings from CSV file.

    Args:
        csv_path: Path to CSV file with format: Thai<TAB>Romanization
        max_entries: Maximum number of entries to load (None = all)

    Returns:
        Dictionary mapping Thai words to list of romanizations
    """
    thai_to_roman = {}

    with open(csv_path, 'r', encoding='utf-8-sig') as f:
        reader = csv.reader(f, delimiter='\t')
        for i, row in enumerate(reader):
            if max_entries and i >= max_entries:
                break

            if len(row) >= 2:
                thai, roman = row[0].strip(), row[1].strip()

                # Skip empty entries
                if not thai or not roman:
                    continue

                # Store original RTGS romanization
                if thai not in thai_to_roman:
                    thai_to_roman[thai] = []
                thai_to_roman[thai].append(roman)

    return thai_to_roman


def rtgs_to_paiboon(rtgs: str) -> str:
    """
    Convert RTGS romanization to Paiboon system (without tone markers).

    RTGS → Paiboon conversions:
    - ph → p (ผ, พ)
    - kh → k (ข, ค)
    - th → t (ท, ธ)
    - ch → j (จ) when at word start
    - initial k → g (ก)

    Args:
        rtgs: RTGS romanization string

    Returns:
        Paiboon romanization string
    """
    result = rtgs

    # Replace digraphs with Paiboon equivalents
    result = result.replace('ph', 'p')
    result = result.replace('kh', 'k')
    result = result.replace('th', 't')

    # ch → j for จ sound (at word start)
    if result.startswith('ch'):
        result = 'j' + result[2:]

    # Initial k → g (for ก in Paiboon)
    if result.startswith('k'):
        result = 'g' + result[1:]

    return result


def generate_vowel_variants(roman: str) -> List[str]:
    """
    Generate common vowel variations for a romanization.

    Examples:
        - sawatdi → sawatdee, sawasdee, sawasdi, sawadee
        - aroi → aloi, aroy

    Args:
        roman: Original romanization

    Returns:
        List of vowel variants (including original)
    """
    variants = {roman}

    # Pattern 1: Final 'i' ↔ 'ee' (sawatdi ↔ sawatdee)
    if roman.endswith('i'):
        variants.add(roman[:-1] + 'ee')
    if roman.endswith('ee'):
        variants.add(roman[:-2] + 'i')

    # Pattern 2: Final 'y' ↔ 'i' ↔ 'ee' (aroy, aroi, aroee)
    if roman.endswith('y'):
        variants.add(roman[:-1] + 'i')
        variants.add(roman[:-1] + 'ee')
    if roman.endswith('i') and len(roman) > 2:
        variants.add(roman[:-1] + 'y')
    if roman.endswith('ee') and len(roman) > 3:
        variants.add(roman[:-2] + 'y')

    # Pattern 3: 't' ↔ 's' (common confusion: sawatdi ↔ sawasdi)
    if 't' in roman:
        variants.add(roman.replace('t', 's'))
    if 's' in roman:
        variants.add(roman.replace('s', 't'))

    # Pattern 4: 't' ↔ 'd' (common confusion: sawatdi ↔ sawaddi)
    if 't' in roman:
        variants.add(roman.replace('t', 'd'))
    if 'd' in roman:
        variants.add(roman.replace('d', 't'))

    # Pattern 5: Long vowel doubling (aa, ee, oo for long vowels)
    if 'a' in roman and 'aa' not in roman:
        variants.add(roman.replace('a', 'aa', 1))  # Only first occurrence
    if 'o' in roman and 'oo' not in roman:
        variants.add(roman.replace('o', 'oo', 1))

    # Pattern 6: Combined transformations for common cases
    # Apply i→ee to all variants that have 't' or 's' transformations
    combined_variants = set()
    for v in list(variants):
        if v.endswith('i'):
            combined_variants.add(v[:-1] + 'ee')
        if v.endswith('ee'):
            combined_variants.add(v[:-2] + 'i')

    variants.update(combined_variants)

    # Pattern 7: Remove 't' before final vowel (sawatdi → sawadi, sawatdee → sawadee)
    # This handles English speakers who drop the 't' sound
    t_removed = set()
    if 'tdi' in roman:
        t_removed.add(roman.replace('tdi', 'di'))
        t_removed.add(roman.replace('tdi', 'dee'))  # Combined: t-drop + i→ee
    if 'tdee' in roman:
        t_removed.add(roman.replace('tdee', 'dee'))
        t_removed.add(roman.replace('tdee', 'di'))  # Combined: t-drop + ee→i
    if 'ti' in roman and len(roman) > 3:
        t_removed.add(roman.replace('ti', 'i'))
        t_removed.add(roman.replace('ti', 'ee'))  # Combined: t-drop + i→ee
    if 'tee' in roman and len(roman) > 4:
        t_removed.add(roman.replace('tee', 'ee'))
        t_removed.add(roman.replace('tee', 'i'))  # Combined: t-drop + ee→i

    variants.update(t_removed)

    # Remove any empty or single-char variants
    variants = {v for v in variants if len(v) >= 2}

    return list(variants)


def create_inverted_index(thai_to_roman: Dict[str, List[str]], freq_map: Dict[str, int]) -> Dict[str, List[str]]:
    """
    Create inverted index from romanization to Thai words.
    Adds ONLY Paiboon variants (vowel variants now computed at runtime in Swift).
    Filters to only words that appear in frequency data.

    Args:
        thai_to_roman: Dictionary mapping Thai words to RTGS romanizations
        freq_map: Dictionary mapping Thai words to frequency counts

    Returns:
        Dictionary mapping romanizations to Thai words (filtered by frequency)
    """
    roman_to_thai = {}

    for thai_word, romanizations in thai_to_roman.items():
        # FILTER: Skip words not in frequency data (uncommon words)
        if thai_word not in freq_map:
            continue

        for rtgs_roman in romanizations:
            # Normalize: lowercase
            rtgs_roman = rtgs_roman.lower().strip()

            if not rtgs_roman:
                continue

            # Collect variants for this romanization
            all_variants: Set[str] = set()

            # 1. Add original RTGS
            all_variants.add(rtgs_roman)

            # 2. Add Paiboon variant
            paiboon = rtgs_to_paiboon(rtgs_roman)
            all_variants.add(paiboon)

            # NOTE: Vowel variants are now generated at runtime in Swift for performance
            # See vowel_variants_backup.py for the original logic

            # 3. Add to inverted index
            for variant in all_variants:
                if variant not in roman_to_thai:
                    roman_to_thai[variant] = []
                if thai_word not in roman_to_thai[variant]:
                    roman_to_thai[variant].append(thai_word)

    return roman_to_thai


def load_frequency_data(freq_path):
    """Load Thai word frequency data from tnc_freq.txt."""
    print(f"Loading frequency data from {freq_path}...")

    freq_map = {}
    with open(freq_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or '\t' not in line:
                continue

            parts = line.split('\t')
            if len(parts) != 2:
                continue

            word, freq = parts
            try:
                freq_map[word] = int(freq)
            except ValueError:
                continue

    print(f"Loaded frequency data for {len(freq_map)} words")
    return freq_map

def main():
    csv_path = "/Users/fsonntag/Developer/thai-phon/thai2rom/data.csv"
    freq_path = "/Users/fsonntag/Developer/thai-phon/tnc_freq.txt"
    output_path = "/Users/fsonntag/Developer/thai-phon/ThaiPhoneticIM/dictionary.json"

    print("Loading Thai romanization data...")
    thai_to_roman = load_thai_romanization_data(csv_path, max_entries=None)

    print("Loading frequency data...")
    freq_map = load_frequency_data(freq_path)

    print("Creating inverted index (filtered by frequency)...")
    roman_to_thai = create_inverted_index(thai_to_roman, freq_map)

    # Sort candidates by: 1) frequency (most common first), 2) length (shorter first)
    dictionary = {}
    for roman, thai_words in roman_to_thai.items():
        sorted_words = sorted(
            thai_words,
            key=lambda word: (
                -freq_map.get(word, 0),  # Negative for descending (most frequent first)
                len(word),                # Shorter words first
                word                      # Alphabetically as tiebreaker
            )
        )
        # Limit to 9 candidates (for number key selection 1-9)
        dictionary[roman] = sorted_words[:9]

    print(f"Exporting {len(dictionary)} entries to JSON...")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(dictionary, f, ensure_ascii=False, indent=2)

    print(f"Dictionary exported to {output_path}")
    print(f"Total romanizations: {len(dictionary)}")
    print(f"Total Thai words: {sum(len(v) for v in dictionary.values())}")

    # Show examples with frequency info
    print("\nExamples (sorted by frequency):")
    test_words = [
        # Test Paiboon variants
        ('gin', 'กิน'),
        ('pom', 'ผม'),
        ('yaak', 'อยาก'),
        # Test RTGS originals still work
        ('kin', 'กิน'),
        ('phom', 'ผม'),
        ('yak', 'อยาก'),
        # Test vowel variants
        ('sawasdee', 'สวัสดี'),
        ('sawatdee', 'สวัสดี'),
        ('sawadee', 'สวัสดี'),
    ]

    print("\nTesting new romanization variants:")
    for word, expected_thai in test_words:
        if word in dictionary:
            candidates = dictionary[word][:5]  # Show top 5
            has_expected = expected_thai in candidates
            status = "✓" if has_expected else "✗"
            print(f"\n  {status} {word} → {expected_thai}")
            for i, candidate in enumerate(candidates, 1):
                freq = freq_map.get(candidate, 0)
                marker = "  ← TARGET" if candidate == expected_thai else ""
                if freq > 0:
                    print(f"    {i}. {candidate} (freq: {freq:,}){marker}")
                else:
                    print(f"    {i}. {candidate} (freq: N/A){marker}")
        else:
            print(f"\n  ✗ {word} → NOT FOUND in dictionary")

if __name__ == '__main__':
    main()
