# Thai Phonetic Input Method

A phonetic input method for typing Thai using romanization (similar to Pinyin for Chinese).

## Components

### macOS Input Method (`ThaiPhoneticIM/`)
Native macOS input method using InputMethodKit. Type romanization and select Thai text from candidates.

See [ThaiPhoneticIM/README.md](ThaiPhoneticIM/README.md) for installation and usage.

### Dictionary Generation
Tools for building the Thai phonetic dictionary from source datasets:

- `export_dictionary_json.py` - Generate dictionary.json from thai2rom dataset
- `fix_duplicates.sh` - Clean up duplicate entries

## Data Sources

The phonetic dictionary is built from:
- **thai2rom** - Thai to romanization mappings (not included in repo)
- **TNC corpus** (tnc_freq.txt) - Word frequency data (not included in repo)

Result: 198,123 romanization entries from 155,442 Thai words

## Future Plans

- Android keyboard implementation
- Additional romanization schemes
- Improved candidate ranking

## License

MIT License
