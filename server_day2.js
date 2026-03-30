const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const crypto = require('crypto');
const sqlite3 = require('sqlite3').verbose();
const ExcelJS = require('exceljs');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, 'runtime');
const PUBLIC_DIR = path.join(__dirname, 'public');
const UPLOADS_DIR = path.join(DATA_DIR, 'uploads');
const GP_DIR = path.join(UPLOADS_DIR, 'giayphep');
const BV_DIR = path.join(UPLOADS_DIR, 'banve');
const DB_PATH = path.join(DATA_DIR, 'data.db');
const ADMIN_USERNAME = process.env.ADMIN_USERNAME || 'admin';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'ChangeMe123!';

for (const dir of [DATA_DIR, UPLOADS_DIR, GP_DIR, BV_DIR]) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(UPLOADS_DIR));

const db = new sqlite3.Database(DB_PATH);

function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}
function createToken() {
  return crypto.randomBytes(32).toString('hex');
}

function run(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.run(sql, params, function (err) {
      if (err) reject(err); else resolve(this);
    });
  });
}
function get(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.get(sql, params, (err, row) => err ? reject(err) : resolve(row));
  });
}
function all(sql, params = []) {
  return new Promise((resolve, reject) => {
    db.all(sql, params, (err, rows) => err ? reject(err) : resolve(rows));
  });
}

async function initDb() {
  await run(`CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT,
    role TEXT DEFAULT 'member',
    is_active INTEGER DEFAULT 1,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
  )`);

  await run(`CREATE TABLE IF NOT EXISTS sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    token TEXT UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    expires_at TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id)
  )`);

  await run(`CREATE TABLE IF NOT EXISTS construction_cases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    maHoSo TEXT,
    chuDauTu TEXT,
    diaChi TEXT,
    apPhuTrach TEXT,
    canBoPhuTrach TEXT,
    tinhTrang TEXT,
    ngayKiemTra TEXT,
    loaiHoSo TEXT,
    ghiChu TEXT,
    soGiayPhep TEXT,
    ngayCapPhep TEXT,
    coQuanCapPhep TEXT,
    loaiBanVe TEXT,
    soTang TEXT,
    dienTichXayDung TEXT,
    dienTichSan TEXT,
    fileBanVe TEXT,
    fileGiayPhep TEXT,
    createdBy INTEGER,
    createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
    updatedAt TEXT,
    FOREIGN KEY(createdBy) REFERENCES users(id)
  )`);

  const admin = await get(`SELECT * FROM users WHERE username = ?`, [ADMIN_USERNAME]);
  if (!admin) {
    await run(
      `INSERT INTO users (username, password_hash, full_name, role) VALUES (?, ?, ?, ?)`,
      [ADMIN_USERNAME, hashPassword(ADMIN_PASSWORD), 'Quản trị hệ thống', 'admin']
    );
    console.log(`Created admin account: ${ADMIN_USERNAME}`);
  }
}

function deleteFileIfExists(fileUrl) {
  try {
    if (!fileUrl || !fileUrl.startsWith('/uploads/')) return;
    const relative = fileUrl.replace('/uploads/', '');
    const full = path.join(UPLOADS_DIR, relative);
    if (fs.existsSync(full)) fs.unlinkSync(full);
  } catch (e) {
    console.error('deleteFileIfExists error:', e.message);
  }
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, file.fieldname === 'fileGiayPhep' ? GP_DIR : BV_DIR),
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname || '');
    const base = path.basename(file.originalname || 'file', ext).replace(/[^\w\-]/g, '_');
    cb(null, `${Date.now()}_${base}${ext}`);
  }
});
const upload = multer({ storage });

async function authRequired(req, res, next) {
  try {
    const auth = req.headers.authorization || '';
    const token = auth.startsWith('Bearer ') ? auth.slice(7) : '';
    if (!token) return res.status(401).json({ success: false, message: 'Chưa đăng nhập' });

    const session = await get(
      `SELECT s.*, u.id as userId, u.username, u.full_name, u.role, u.is_active
       FROM sessions s JOIN users u ON u.id = s.user_id
       WHERE s.token = ?`,
      [token]
    );
    if (!session) return res.status(401).json({ success: false, message: 'Phiên đăng nhập không hợp lệ' });
    if (session.is_active !== 1) return res.status(403).json({ success: false, message: 'Tài khoản đã bị khóa' });
    if (new Date(session.expires_at) < new Date()) {
      await run(`DELETE FROM sessions WHERE token = ?`, [token]);
      return res.status(401).json({ success: false, message: 'Phiên đăng nhập đã hết hạn' });
    }
    req.user = {
      id: session.userId,
      username: session.username,
      fullName: session.full_name,
      role: session.role,
      token,
    };
    next();
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
}

app.get('/health', (req, res) => res.json({ ok: true }));

app.post('/api/auth/login', async (req, res) => {
  try {
    const { username, password } = req.body || {};
    const user = await get(`SELECT * FROM users WHERE username = ?`, [username || '']);
    if (!user) return res.status(401).json({ success: false, message: 'Sai tài khoản hoặc mật khẩu' });
    if (user.password_hash !== hashPassword(password || '')) {
      return res.status(401).json({ success: false, message: 'Sai tài khoản hoặc mật khẩu' });
    }
    const token = createToken();
    const expiresAt = new Date(Date.now() + 1000 * 60 * 60 * 24 * 7).toISOString();
    await run(`INSERT INTO sessions (token, user_id, expires_at) VALUES (?, ?, ?)`, [token, user.id, expiresAt]);
    res.json({
      success: true,
      token,
      user: {
        id: user.id,
        username: user.username,
        fullName: user.full_name,
        role: user.role,
      }
    });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

app.post('/api/auth/logout', authRequired, async (req, res) => {
  await run(`DELETE FROM sessions WHERE token = ?`, [req.user.token]);
  res.json({ success: true });
});

app.get('/api/auth/me', authRequired, async (req, res) => {
  res.json({ success: true, user: req.user });
});

app.post('/api/users', authRequired, async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ success: false, message: 'Chỉ admin được tạo tài khoản' });
    const { username, password, fullName, role } = req.body || {};
    if (!username || !password) return res.status(400).json({ success: false, message: 'Thiếu username hoặc password' });
    await run(
      `INSERT INTO users (username, password_hash, full_name, role) VALUES (?, ?, ?, ?)`,
      [username, hashPassword(password), fullName || username, role || 'member']
    );
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

app.get('/api/cases', authRequired, async (req, res) => {
  try {
    const rows = await all(`SELECT * FROM construction_cases ORDER BY id DESC`);
    res.json({ success: true, data: rows });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

app.post('/api/cases', authRequired, upload.fields([{ name: 'fileGiayPhep', maxCount: 1 }, { name: 'fileBanVe', maxCount: 1 }]), async (req, res) => {
  try {
    const body = req.body || {};
    const fileGiayPhep = req.files?.fileGiayPhep?.[0] ? `/uploads/giayphep/${req.files.fileGiayPhep[0].filename}` : '';
    const fileBanVe = req.files?.fileBanVe?.[0] ? `/uploads/banve/${req.files.fileBanVe[0].filename}` : '';
    const result = await run(`INSERT INTO construction_cases (
      maHoSo, chuDauTu, diaChi, apPhuTrach, canBoPhuTrach, tinhTrang,
      ngayKiemTra, loaiHoSo, ghiChu, soGiayPhep, ngayCapPhep, coQuanCapPhep,
      loaiBanVe, soTang, dienTichXayDung, dienTichSan, fileBanVe, fileGiayPhep,
      createdBy, updatedAt
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`, [
      body.maHoSo || '', body.chuDauTu || '', body.diaChi || '', body.apPhuTrach || '', body.canBoPhuTrach || '',
      body.tinhTrang || 'Đang xử lý', body.ngayKiemTra || '', body.loaiHoSo || '', body.ghiChu || '',
      body.soGiayPhep || '', body.ngayCapPhep || '', body.coQuanCapPhep || '', body.loaiBanVe || '',
      body.soTang || '', body.dienTichXayDung || '', body.dienTichSan || '', fileBanVe, fileGiayPhep,
      req.user.id, new Date().toISOString()
    ]);
    const row = await get(`SELECT * FROM construction_cases WHERE id = ?`, [result.lastID]);
    res.json({ success: true, data: row });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

app.put('/api/cases/:id', authRequired, upload.fields([{ name: 'fileGiayPhep', maxCount: 1 }, { name: 'fileBanVe', maxCount: 1 }]), async (req, res) => {
  try {
    const oldRow = await get(`SELECT * FROM construction_cases WHERE id = ?`, [req.params.id]);
    if (!oldRow) return res.status(404).json({ success: false, message: 'Không tìm thấy hồ sơ' });

    let newFileGiayPhep = oldRow.fileGiayPhep;
    let newFileBanVe = oldRow.fileBanVe;
    if (req.files?.fileGiayPhep?.[0]) {
      newFileGiayPhep = `/uploads/giayphep/${req.files.fileGiayPhep[0].filename}`;
      deleteFileIfExists(oldRow.fileGiayPhep);
    }
    if (req.files?.fileBanVe?.[0]) {
      newFileBanVe = `/uploads/banve/${req.files.fileBanVe[0].filename}`;
      deleteFileIfExists(oldRow.fileBanVe);
    }

    await run(`UPDATE construction_cases SET
      maHoSo=?, chuDauTu=?, diaChi=?, apPhuTrach=?, canBoPhuTrach=?, tinhTrang=?,
      ngayKiemTra=?, loaiHoSo=?, ghiChu=?, soGiayPhep=?, ngayCapPhep=?, coQuanCapPhep=?,
      loaiBanVe=?, soTang=?, dienTichXayDung=?, dienTichSan=?, fileBanVe=?, fileGiayPhep=?, updatedAt=?
      WHERE id=?`, [
      req.body.maHoSo || '', req.body.chuDauTu || '', req.body.diaChi || '', req.body.apPhuTrach || '', req.body.canBoPhuTrach || '',
      req.body.tinhTrang || 'Đang xử lý', req.body.ngayKiemTra || '', req.body.loaiHoSo || '', req.body.ghiChu || '',
      req.body.soGiayPhep || '', req.body.ngayCapPhep || '', req.body.coQuanCapPhep || '', req.body.loaiBanVe || '',
      req.body.soTang || '', req.body.dienTichXayDung || '', req.body.dienTichSan || '', newFileBanVe, newFileGiayPhep,
      new Date().toISOString(), req.params.id
    ]);
    const row = await get(`SELECT * FROM construction_cases WHERE id = ?`, [req.params.id]);
    res.json({ success: true, data: row });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

app.delete('/api/cases/:id', authRequired, async (req, res) => {
  try {
    const row = await get(`SELECT * FROM construction_cases WHERE id = ?`, [req.params.id]);
    if (!row) return res.status(404).json({ success: false, message: 'Không tìm thấy hồ sơ' });
    deleteFileIfExists(row.fileGiayPhep);
    deleteFileIfExists(row.fileBanVe);
    await run(`DELETE FROM construction_cases WHERE id = ?`, [req.params.id]);
    res.json({ success: true });
  } catch (e) {
    res.status(500).json({ success: false, message: e.message });
  }
});

app.get('/api/export/excel', authRequired, async (req, res) => {
  try {
    const rows = await all(`SELECT * FROM construction_cases ORDER BY id DESC`);
    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Ho so xay dung');
    worksheet.columns = [
      { header: 'ID', key: 'id', width: 8 },
      { header: 'Mã hồ sơ', key: 'maHoSo', width: 15 },
      { header: 'Chủ đầu tư', key: 'chuDauTu', width: 25 },
      { header: 'Địa chỉ', key: 'diaChi', width: 35 },
      { header: 'Ấp', key: 'apPhuTrach', width: 12 },
      { header: 'Cán bộ', key: 'canBoPhuTrach', width: 18 },
      { header: 'Tình trạng', key: 'tinhTrang', width: 15 },
      { header: 'Ngày kiểm tra', key: 'ngayKiemTra', width: 15 },
      { header: 'Giấy phép', key: 'soGiayPhep', width: 18 }
    ];
    worksheet.getRow(1).font = { bold: true };
    rows.forEach((r) => worksheet.addRow(r));
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename="ho_so_xay_dung.xlsx"');
    await workbook.xlsx.write(res);
    res.end();
  } catch (e) {
    res.status(500).send('Lỗi xuất Excel');
  }
});

if (fs.existsSync(path.join(PUBLIC_DIR, 'index.html'))) {
  app.use(express.static(PUBLIC_DIR));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api/') || req.path.startsWith('/uploads/')) return next();
    res.sendFile(path.join(PUBLIC_DIR, 'index.html'));
  });
}

initDb().then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running at port ${PORT}`);
    console.log(`DB: ${DB_PATH}`);
  });
}).catch((e) => {
  console.error('initDb failed:', e);
  process.exit(1);
});
