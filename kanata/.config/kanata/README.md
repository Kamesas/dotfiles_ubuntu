# Kanata

- To Enable: sudo systemctl start kanata
- To Disable: sudo systemctl stop kanata
- To Check Status: systemctl status kanata

### To reload and see status (shows error or success )

sudo systemctl restart kanata
systemctl status kanata

sudo nano /etc/kanata/kanata.kbd

sudo systemctl daemon-reload
sudo systemctl enable kanata
sudo systemctl start kanata

sudo systemctl disable kanata - disable from autostrt
sudo systemctl stop kanata

sudo killall kanata

# 1. Create the folder in your user config

mkdir -p ~/.config/kanata

# 2. Copy the current working file to this new folder

# We will name this one 'kanata-laptop.kbd' (or 'kanata-gmk70.kbd' if it has both)

sudo cp /etc/kanata/kanata.kbd ~/.config/kanata/kanata-mixed.kbd

# 3. Take ownership of the file (since sudo cp makes it root-owned)

sudo chown $USER:$USER ~/.config/kanata/kanata-mixed.kbd

# Force create a symbolic link (-f overwrites existing files)

sudo ln -sf ~/.config/kanata/kanata-mixed.kbd /etc/kanata/kanata.kbd

Now you can edit it with LazyVim: You no longer need sudo to edit. Just run:
ls -l /etc/kanata/kanata.kbd
