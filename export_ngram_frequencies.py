#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Export n-gram frequencies from PyThaiNLP for use in the input method.
This creates a compact JSON file with:
1. Word frequencies (unigrams)
2. Bigram frequencies (word pairs)
3. Trigram frequencies (word triples)
"""

import json
from pythainlp.corpus import tnc

def export_ngram_frequencies(output_path: str, top_n_bigrams: int = 50000, top_n_trigrams: int = 10000):
    """
    Export n-gram frequencies to JSON.

    Args:
        output_path: Path to output JSON file
        top_n_bigrams: Number of top bigrams to include (to keep file small)
        top_n_trigrams: Number of top trigrams to include
    """
    print("Loading n-gram frequencies from PyThaiNLP TNC corpus...")

    # Get bigram and trigram frequencies
    print("Loading bigrams...")
    bigram_freqs = tnc.bigram_word_freqs()

    print("Loading trigrams...")
    trigram_freqs = tnc.trigram_word_freqs()

    # Sort and take top N to reduce file size
    print(f"Sorting bigrams (keeping top {top_n_bigrams})...")
    sorted_bigrams = sorted(bigram_freqs.items(), key=lambda x: x[1], reverse=True)[:top_n_bigrams]

    print(f"Sorting trigrams (keeping top {top_n_trigrams})...")
    sorted_trigrams = sorted(trigram_freqs.items(), key=lambda x: x[1], reverse=True)[:top_n_trigrams]

    # Convert to simple dict format for JSON
    # Bigrams: {"ผม|กิน": 1234}  (using | as separator)
    bigram_dict = {
        f"{w1}|{w2}": freq
        for (w1, w2), freq in sorted_bigrams
    }

    # Trigrams: {"ผม|กิน|ข้าว": 567}
    trigram_dict = {
        f"{w1}|{w2}|{w3}": freq
        for (w1, w2, w3), freq in sorted_trigrams
    }

    # Create output structure
    data = {
        "bigrams": bigram_dict,
        "trigrams": trigram_dict
    }

    print(f"\nExporting to {output_path}...")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=None)  # No indent for smaller file

    # Print statistics
    import os
    file_size = os.path.getsize(output_path) / (1024 * 1024)  # MB

    print(f"\n✓ Export complete!")
    print(f"  Bigrams: {len(bigram_dict):,}")
    print(f"  Trigrams: {len(trigram_dict):,}")
    print(f"  File size: {file_size:.1f} MB")

    # Show some examples
    print("\nExample bigrams:")
    for (w1_w2, freq) in list(bigram_dict.items())[:5]:
        w1, w2 = w1_w2.split('|')
        print(f"  {w1} + {w2} = {freq:,}")

    print("\nExample trigrams:")
    for (w1_w2_w3, freq) in list(trigram_dict.items())[:5]:
        w1, w2, w3 = w1_w2_w3.split('|')
        print(f"  {w1} + {w2} + {w3} = {freq:,}")

    # Test: Check if our test phrase exists
    test_bigram = "กิน|ข้าว"
    if test_bigram in bigram_dict:
        print(f"\n✓ Test bigram 'กิน ข้าว' found: {bigram_dict[test_bigram]:,} occurrences")
    else:
        print(f"\n✗ Test bigram 'กิน ข้าว' not in top {top_n_bigrams}")

    test_trigram = "ผม|กิน|ข้าว"
    if test_trigram in trigram_dict:
        print(f"✓ Test trigram 'ผม กิน ข้าว' found: {trigram_dict[test_trigram]:,} occurrences")
    else:
        print(f"✗ Test trigram 'ผม กิน ข้าว' not in top {top_n_trigrams}")

if __name__ == '__main__':
    output_path = "/Users/fsonntag/Developer/thai-phon/ThaiPhoneticIM/ngram_frequencies.json"
    export_ngram_frequencies(output_path, top_n_bigrams=50000, top_n_trigrams=10000)
