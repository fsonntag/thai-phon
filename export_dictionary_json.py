#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Export Thai romanization dictionary to JSON for InputMethodKit
Sorts candidates by frequency (most common words first)
"""

import json
import sys
sys.path.insert(0, '.')
from generate_inputplugin import load_thai_romanization_data, create_inverted_index

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

    print("Creating inverted index...")
    roman_to_thai = create_inverted_index(thai_to_roman)

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
    test_words = ['sawasdee', 'khrap', 'krap', 'aroi', 'mai', 'kao', 'pen']
    for word in test_words:
        if word in dictionary:
            candidates = dictionary[word][:5]  # Show top 5
            print(f"\n  {word}:")
            for i, candidate in enumerate(candidates, 1):
                freq = freq_map.get(candidate, 0)
                if freq > 0:
                    print(f"    {i}. {candidate} (freq: {freq:,})")
                else:
                    print(f"    {i}. {candidate} (freq: N/A)")

if __name__ == '__main__':
    main()
