# Branding Hooks

`apply-branding.sh` is executed inside the target rootfs (for example via a preseed `late_command`).
It installs a generated teal wallpaper, updates Cinnamon defaults, and brands the LightDM greeter.

Run manually during testing with:
```bash
sudo chroot /mnt/target /aetheros/branding/apply-branding.sh
```
