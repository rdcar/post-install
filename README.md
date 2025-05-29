### Script to automate the installation of applications and bug fixes for Ubuntu 24.04 LTS based distros.

The script adds the necessary repositories and installs the following applications:
* VLC Media Player (org.videolan.VLC)
* Spotify (com.spotify.Client)
* GIMP (org.gimp.GIMP)
* Brave Browser (com.brave.Browser)
* Calibre (com.calibre_ebook.calibre)
* Foliate (com.github.johnfactotum.Foliate)
* TeamSpeak 3 (com.teamspeak.TeamSpeak3)
* qBittorrent (org.qbittorrent.qBittorrent)
* PeaZip (io.github.peazip.PeaZip)
* JDownloader (org.jdownloader.JDownloader)
* Video Downloader (com.github.unrud.VideoDownloader)
* Pdf4Qt (io.github.JakubMelka.Pdf4qt)
* Thunderbird (org.mozilla.Thunderbird)
* LocalSend (org.localsend.localsend_app)
* Impression (io.gitlab.adhami3310.Impression)
* CPU-X (io.github.thetumultuousunicornofdarkness.cpu-x)
* NetworkDisplays (org.gnome.NetworkDisplays)
* Github CLI (apt)
* Nala (apt)
* Neofetch (apt)
* wget & curl (apt)
* Tailscale

### Fixes the common audio Dummy Output & HDMI-output error on some soundboards on kernel 6.8+

    echo "options snd-hda-intel dmic_detect=0" | sudo tee -a /etc/modprobe.d/alsa-base.conf echo "blacklist snd_soc_skl" | sudo tee -a /etc/modprobe.d/blacklist.conf
### Fix for blurry image on brave browser when using fractional scaling resolutions

    brave://flags/
    select "Preferred Ozone platform" change to "Wayland"

### Adds firewall rules for GSConnect / KDE Connect / Zorin Connect

```bash 
sudo ufw allow 1714:1764/udp 
sudo ufw allow 1714:1764/tcp 
sudo ufw reload
```

### How to use:
1. Create a file named `post-install.sh`.
2. Grant execution permission:
`chmod +x post-install.sh`
4. Run the script:
   `./post-install.sh`
