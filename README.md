# 🔐 Tor Anonymity Toolkit

A powerful Bash-based toolkit that lets you easily control and monitor your Tor anonymity with systemd integration, IP rotation, live dashboards, and optional desktop notifications.

![screenshot](docs/demo.png) <!-- optional, if you'll add screenshots -->

---

## 🚀 Features

- ✅ **Toggle Tor & NEWNYM**: One-click start/stop for Tor and timed identity changes.
- 🕒 **Automated IP Rotation**: Sends `NEWNYM` signal every 10 minutes using `systemd` timers.
- 📡 **Traffic Check**: Verifies if your traffic is routed through Tor with multiple IP checkers.
- 🔁 **Live IP Monitor**: Monitor Tor IP changes in real-time.
- 🧠 **Interactive Menu**: User-friendly TUI (Text UI) for all controls.
- 🔔 **Desktop Notifications**: Optional notify-send popups on IP change or failure.
- 🎨 **Theme Support**: Light/dark terminal color themes.
- 🔧 **Customizable Config**: Easily override defaults via `~/.anonymity.conf`.

---

## 🛠 Installation

### 1. Clone the repo

```bash
git clone https://github.com/Hao-Tec/tor-anonymity-toolkit.git
cd tor-anonymity-toolkit
2. Make the script executable
bash
Copy code
chmod +x anonymity.sh
3. (Optional) Run the setup script
bash
Copy code
./anonymity.sh setup
This creates systemd user timer/service files for automatic IP rotation every 10 minutes.

🧪 Usage
🔘 Basic Commands
bash
Copy code
./anonymity.sh toggle        # Toggle both Tor and NEWNYM timer
./anonymity.sh newnym        # Send NEWNYM signal
./anonymity.sh check         # Check if traffic is via Tor
./anonymity.sh status        # Show status of services
./anonymity.sh monitor       # Run live ephemeral IP monitor
./anonymity.sh dashboard     # Show recent IP logs and statuses
📲 Interactive Mode
bash
Copy code
./anonymity.sh menu
This launches the full control panel with all options.

⚙ Configuration
When run for the first time, a config file is auto-created at:

bash
Copy code
~/.anonymity.conf
Edit this file to adjust:

bash
Copy code
AUTH_PASSWORD="ACILAB"    # Control port password
ENABLE_NOTIF=1            # Set 0 to disable desktop notifications
THEME="dark"              # Choose 'dark' or 'light'
🐧 Requirements
Make sure the following tools are installed:

bash
Copy code
sudo apt install tor curl netcat expect telnet systemd
🧩 Advanced Tips
Use ./anonymity.sh setup to auto-create required systemd user services.

Add the script to your system PATH or create an alias for quick access.

Enable persistent Tor by checking tor@default.service if needed.

📄 License
This project is licensed under the MIT License.

🤝 Contributing
Contributions, suggestions, and improvements are always welcome!
Just fork the repo and submit a pull request.

🙌 Author
Made with ❤️ by Hao-Tec

yaml
Copy code

---

### ✅ What You Should Do Next:

1. **Create the `README.md`** file:
```bash
nano README.md
