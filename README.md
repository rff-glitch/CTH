# Archive Password Cracker 🔓

A powerful bash tool for cracking password-protected archives (ZIP, RAR, 7z) using John the Ripper and Hashcat.

## 🚀 Features

- Multiple Archive Support: Crack ZIP, RAR, and 7z files
- Smart Bruteforce: Configurable character sets and length ranges
- Session Management: Pause/resume attacks at any time
- Automatic Setup: Installs all dependencies automatically
- Clean Interface: Simple, no-frills command-line interface
- High Performance: Leverages Hashcat's GPU acceleration

## 📦 Installation

Clone the repository:
git clone https://github.com/rff-glitch/archive-cracker.git
cd archive-cracker

Make script executable:
chmod +x tool.sh

## 🛠️ Requirements

- Ubuntu/Debian Linux
- sudo privileges
- Internet connection (for initial setup)
- NVIDIA/AMD GPU (recommended for speed)

## 🎯 Usage

Basic Attack:
sudo ./tool.sh encrypted.zip

Resume Paused Attack:
sudo ./tool.sh encrypted.zip --resume

Stop Running Attack:
sudo ./tool.sh encrypted.zip --stop

Short Flags:
sudo ./tool.sh file.rar -r    # Resume
sudo ./tool.sh file.7z -s     # Stop

## 📋 How It Works

1. Extracts hash from archive using John the Ripper
2. Configures attack based on your character set and length preferences
3. Runs Hashcat with optimized settings
4. Manages sessions allowing pause/resume functionality

Attack Configuration Options:
- Numbers only (0-9)
- Lowercase letters (a-z)
- Uppercase letters (A-Z)
- Mixed case (a-z, A-Z)
- Alphanumeric (a-z, A-Z, 0-9)
- All characters

Length Range:
- Specify minimum and maximum password length
- Default: 1-8 characters
- Supports any range (e.g., 4-12 characters)

## 📊 Performance

- CPU Mode: ~100-1000 hashes/second
- GPU Mode: ~10,000-100,000+ hashes/second (depending on GPU)
- Session files: Automatically saved for resuming
- Progress tracking: Real-time status updates

## 🔧 Technical Details

Supported Archive Formats:
- ZIP: Mode 13600 (PKZIP)
- RAR: Mode 13000 (RAR5)
- 7z: Mode 11600 (7-Zip)

Dependencies Installed:
- John the Ripper Jumbo
- Hashcat
- 7zip, RAR, unzip
- Build tools and libraries

## ⚡ Examples

Example 1: Crack ZIP with numbers
sudo ./tool.sh document.zip
Select: 1 (Numbers)
Min: 4
Max: 6

Example 2: Resume previous attack
sudo ./tool.sh backup.rar --resume

Example 3: Complex password attack
sudo ./tool.sh secret.7z
Select: 5 (Alphanumeric)
Min: 8
Max: 12

## 🛡️ Legal Disclaimer

⚠️ This tool is for legal purposes only:

- Recovering your own lost passwords
- Educational purposes
- Authorized penetration testing
- Forensic investigations

Do NOT use this tool for:
- Unauthorized access to systems
- Cracking passwords without permission
- Any illegal activities

The author is not responsible for any misuse of this tool.

## 🤝 Contributing

Contributions are welcome! Here's how:

1. Fork the repository
2. Create a feature branch (git checkout -b feature/amazing-feature)
3. Commit your changes (git commit -m 'Add amazing feature')
4. Push to the branch (git push origin feature/amazing-feature)
5. Open a Pull Request

Development Setup:
Test on a dummy archive:
zip -P test123 test.zip README.md
sudo ./tool.sh test.zip

## 📝 Changelog

v2.0.0
- Initial release
- Support for ZIP, RAR, 7z
- Resume/stop functionality
- Configurable character sets
- Length range selection

## 🙏 Credits

Created by: rff-glitch (Raef) (https://github.com/rff-glitch)

Powered by:
- John the Ripper (https://github.com/openwall/john)
- Hashcat (https://hashcat.net/hashcat/)
- Open source community

## 📄 License

MIT License

## ❓ FAQ

Q: Why do I need sudo?
A: The tool needs root to install system packages and for optimal Hashcat performance.

Q: Can I run this on Windows?
A: No, this tool is designed for Linux systems with bash.

Q: How do I know if my GPU is being used?
A: Hashcat automatically detects and uses available GPUs. You'll see much higher speeds with GPU.

Q: Can I crack Word/PDF files?
A: No, this tool only works with archive files (ZIP, RAR, 7z).

Q: What's the success rate?
A: Depends on password complexity and your computing power. Simple passwords are cracked quickly.

## ⭐ Support

If you find this tool useful, please:
- Star the repository ⭐
- Report issues 
- Share with others 

---

Happy (legal) cracking! 🔓

Remember: With great power comes great responsibility.
