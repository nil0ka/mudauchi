# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**mudauchi** - A project that generates commits until finding interesting commit hash patterns.

This is a probabilistic experiment combining:
- Cryptographic hash analysis (SHA-1)
- Probability theory (geometric distribution, birthday paradox)
- Software engineering (Git automation)

## How It Works

The project runs automated commits until finding a hash with **5+ consecutive identical characters** (e.g., `aaaaa`, `77777`).

**Expected iterations**: ~1,821 attempts (calculated from probability theory)

## Commands

```bash
# Run the hash finder (Bash version - recommended)
./find_interesting_hash.sh

# Python version (requires Python 3)
./find_interesting_hash.py
```

Both scripts:
- Create commits with incrementing counter
- Check each commit hash for patterns
- Stop when finding 5+ consecutive characters
- Have 10,000 attempt limit

## Key Files

- `find_interesting_hash.sh` - Main Bash script
- `find_interesting_hash.py` - Python version (same logic)
- `README.md` - Full mathematical analysis (in Japanese)
- `counter.txt` - Generated file tracking attempt count

## Current Target

**5 consecutive characters** (updated from 4)
- Probability: ~1/1,821 per attempt
- Realistic to find within 10,000 attempts (~81% success rate)

## Development Notes

- Probability calculations assume uniform random distribution of SHA-1 output
- The project validates theoretical probability against empirical results
- Git history itself serves as proof-of-work (tamper-resistant verification)
