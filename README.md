# hsgq OLT SNMP REST API

REST API untuk monitoring OLT **hsgq-G04ID** dan **hsgq-G02ID** via SNMP.

## Quick Start

```bash
cp .env.example .env
nano .env
./start.sh
```

## File

| File | Deskripsi |
|---|---|
| `hsgq` | Binary executable |
| `.env` | Config (wajib, gitignored) |
| `env.example` | Template config |
| `start.sh` | Startup script |
| `hsgq.service` | Systemd unit file |

## .env

```bash
# Wajib
SNMP_HOST=          # IP OLT
SNMP_PORT=          # SNMP port
SNMP_COMMUNITY=     # SNMP community

# Optional
SERVER_PORT=8080        # HTTP port (default: 8080)
REFRESH_INTERVAL=5m     # Cache refresh interval
```

## API Endpoints

| Endpoint | Deskripsi |
|---|---|
| `GET /health` | Health check |
| `GET /api/v1/device` | Info OLT (model, serial, firmware, jumlah port) |
| `GET /api/v1/ports` | Semua port + jumlah ONU |
| `GET /api/v1/ports/{port}` | Semua ONU di port (contoh: `/PON01`) |
| `GET /api/v1/ports/{port}/{onu_id}` | Detail single ONU (contoh: `/PON01/0`) |

## Contoh Curl

```bash
# Health
curl http://127.0.0.1:8080/health

# Device info
curl http://127.0.0.1:8080/api/v1/device | jq

# Semua port
curl http://127.0.0.1:8080/api/v1/ports | jq

# ONU per port
curl http://127.0.0.1:8080/api/v1/ports/PON01 | jq

# Detail single ONU
curl http://127.0.0.1:8080/api/v1/ports/PON01/0 | jq

# Filter ONU offline
curl http://127.0.0.1:8080/api/v1/ports/PON01 | jq '.onus[] | select(.state=="offline")'

# Summary redaman per PON
curl http://127.0.0.1:8080/api/v1/ports/PON01 | jq -r '
  .onus | map(select(.state=="online")) |
  "PON01: \(length) online, Rx avg: \([.[].rx_power_dbm] | add / length | . * 100 | round / 100) dBm"
'
```

## JSON Output

```json
{
  "onu_id": 0,
  "name": "NAMA pelanggan",
  "state": "online",
  "vendor": "HWTC",
  "model": "MONUH143",
  "serial": "HWTCA9089620",
  "distance_m": 3718,
  "rx_power_dbm": -24,
  "tx_power_dbm": 1.41,
  "olt_rx_power_dbm": -30.45,
  "bias_current_ma": 11.33,
  "voltage_v": 3.26,
  "uptime": "0d 3h 58m 57s",
  "last_up_time": "2026/07/09 20:30:07",
  "firmware": "ZL_V2.2.1.1"
}
```

## OID Reference

| Field | OID | Scale |
|---|---|---|
| Rx Power (ONU) | `.3.12.3.1.4.{ifIndex}.0.0` | /100 = dBm |
| Rx Power (OLT) | `.3.12.3.1.4.{ifIndex}.65535.65535` | /100 = dBm |
| Tx Power | `.3.12.3.1.5.{ifIndex}.0.0` | /100 = dBm |
| Bias Current | `.3.12.3.1.6.{ifIndex}.0.0` | /100 = mA |
| Voltage | `.3.12.3.1.7.{ifIndex}.0.0` | /100 = V |
| Distance | `.3.12.2.1.19.{ifIndex}` | meter |
| ONU Name | `.3.12.2.1.2.{ifIndex}` | string |
| Status | `.3.12.2.1.3.{ifIndex}` | 0/1 |
| Vendor | `.3.12.2.1.8.{ifIndex}` | string |
| Model | `.3.12.2.1.9.{ifIndex}` | string |
| Serial | `.3.12.2.1.15.{ifIndex}` | hex decode |
| Firmware | `.3.12.2.1.13.{ifIndex}` | string |
| Last Up Time | `.3.12.2.1.20.{ifIndex}` | datetime |
| Uptime | `.3.12.2.1.21.{ifIndex}` | timeticks |

## Systemd

```bash
cp hsgq.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now hsgq
journalctl -u hsgq -f
```

## Multi-OLT

```bash
# OLT 1
cp .env.example olt1/.env
# isi SNMP_PORT=32145, SERVER_PORT=8080

# OLT 2
cp .env.example olt2/.env
# isi SNMP_PORT=32146, SERVER_PORT=8081
```

## Vendor Prefix

| Prefix | Vendor |
|---|---|
| HWTC | Huawei |
| ZICG / ZXIC / ZTEG | ZTE |
| CIOT | CICT |
| RTEG | Radore |
| ELWG | ELsys |
| CMDC | Commscope |
| FHTT | FiberHome |

## Catatan

- ONU ID mulai dari **0**
- Serial di-decode dari hex (4 byte vendor + 4 byte UID)
- Server bind **localhost only** (127.0.0.1)
- Cache auto-refresh setiap 5 menit
- Tidak ada hardcoded sensitive data
