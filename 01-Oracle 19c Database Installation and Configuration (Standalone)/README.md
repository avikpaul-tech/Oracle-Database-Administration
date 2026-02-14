This activity is to install and configure standalone oracle 19c database.
Oracle database version : 19.3
OS version : Oracle linux 7.9

Environment details:
Hostname : srcdb
Oracle database user/group : oracle/oinstall
Mountpoints used : /u01, /data, /arch, /fra
Owner of the mountpoints: oracle
Script location: /scripts
Script log location: /scripts/log


# Oracle 19c Standalone Installation & Configuration

## 📌 Overview
This activity covers the installation and configuration of a standalone Oracle Database 19c environment using silent mode.

---

## 🗄 Database Details

| Parameter | Value |
|------------|--------|
| Oracle Version | 19.3 |
| Database Type | Standalone |
| OS Version | Oracle Linux 7.9 |

---

## 🖥 Environment Details

| Component | Value |
|------------|--------|
| Hostname | `srcdb` |
| Oracle User | `oracle` |
| Oracle Group | `oinstall` |

---

## 📁 Mount Points

| Mount Point | Purpose |
|--------------|----------|
| `/u01` | Oracle Base / Software |
| `/data` | Datafiles |
| `/arch` | Archive Logs |
| `/fra` | Fast Recovery Area |

> All mount points are owned by: `oracle`

---

## 📂 Script Locations

| Type | Path |
|------|------|
| Script Directory | `/scripts` |
| Log Directory | `/scripts/log` |

---

## ⚙️ Installation Flow

1. OS prerequisite configuration
2. Package installation
3. Oracle 19c software installation
4. Database creation (CDB + PDB)
5. Archive log configuration
6. FRA configuration
7. Post-install validation

---

## 🔐 Best Practices Followed

- Silent installation using response files
- Structured script logging
- Dedicated archive and FRA mount points
- Proper OS user and group ownership
