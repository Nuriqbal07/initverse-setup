#!/bin/bash

# Konfigurasi awal
WALLET="0x440aF1B7BE0e5948F6700f22F42B6a62E39215aE"
WORKER="Worker01"
POOL="b"  # Pilihan: a, b, atau c
CORES=(0 1 2)

# Direktori install
INSTALL_DIR="$HOME/initverse"
BIN_URL="https://github.com/Project-InItVerse/ini-miner/releases/latest/download/iniminer-linux-x64"
SERVICE_NAME="initverse-miner"

# Buat direktori
mkdir -p $INSTALL_DIR
cd $INSTALL_DIR

# Unduh binary
wget -O iniminer $BIN_URL
chmod +x iniminer

# Buat script mining
cat > start.sh <<EOF
#!/bin/bash
./iniminer --pool stratum+tcp://$WALLET.$WORKER@pool-$POOL.yatespool.com:32488 \
$(for core in "${CORES[@]}"; do echo -n "--cpu-devices $core "; done)
EOF

chmod +x start.sh

# Buat systemd service
sudo tee /etc/systemd/system/$SERVICE_NAME.service > /dev/null <<EOF
[Unit]
Description=InitVerse Miner
After=network.target

[Service]
User=$USER
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/start.sh
Restart=always
Nice=10
Environment=HOME=$HOME

[Install]
WantedBy=multi-user.target
EOF

# Enable dan start
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "InitVerse miner telah diinstall dan dijalankan sebagai service systemd: $SERVICE_NAME"
