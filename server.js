const express = require('express');
const cors = require('cors');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sqlite3 = require('sqlite3').verbose();
const ExcelJS = require('exceljs');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_DIR = process.env.DATA_DIR || path.join(__dirname, 'runtime');
const APP_BASE_URL = process.env.APP_BASE_URL || '';
const PUBLIC_DIR = path.join(__dirname, 'public');
const UPLOADS_DIR = path.join(DATA_DIR, 'uploads');
const GP_DIR = path.join(UPLOADS_DIR, 'giayphep');
const BV_DIR = path.join(UPLOADS_DIR, 'banve');
const DB_PATH = path.join(DATA_DIR, 'data.db');

for (const dir of [DATA_DIR, UPLOADS_DIR, GP_DIR, BV_DIR]) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(UPLOADS_DIR));

const db = new sqlite3.Database(DB_PATH);

db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS construction_cases (
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
      createdAt TEXT DEFAULT CURRENT_TIMESTAMP
    )
  `);
});

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
  destination: (req, file, cb) => {
    cb(null, file.fieldname === 'fileGiayPhep' ? GP_DIR : BV_DIR);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname || '');
    const base = path.basename(file.originalname || 'file', ext).replace(/[^\w\-]/g, '_');
    cb(null, `${Date.now()}_${base}${ext}`);
  }
});
const upload = multer({ storage });

app.get('/health', (req, res) => {
  res.json({ ok: true, db: DB_PATH, baseUrl: APP_BASE_URL || null });
});

app.get('/api/cases', (req, res) => {
  db.all(`SELECT * FROM construction_cases ORDER BY id DESC`, [], (err, rows) => {
    if (err) return res.status(500).json({ success: false, message: err.message });
    res.json({ success: true, data: rows });
  });
});

app.post('/api/cases', upload.fields([{ name: 'fileGiayPhep', maxCount: 1 }, { name: 'fileBanVe', maxCount: 1 }]), (req, res) => {
  const body = req.body;
  const fileGiayPhep = req.files?.fileGiayPhep?.[0] ? `/uploads/giayphep/${req.files.fileGiayPhep[0].filename}` : '';
  const fileBanVe = req.files?.fileBanVe?.[0] ? `/uploads/banve/${req.files.fileBanVe[0].filename}` : '';
  const sql = `INSERT INTO construction_cases (
    maHoSo, chuDauTu, diaChi, apPhuTrach, canBoPhuTrach, tinhTrang,
    ngayKiemTra, loaiHoSo, ghiChu, soGiayPhep, ngayCapPhep, coQuanCapPhep,
    loaiBanVe, soTang, dienTichXayDung, dienTichSan, fileBanVe, fileGiayPhep
  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`;
  const values = [
    body.maHoSo || '', body.chuDauTu || '', body.diaChi || '', body.apPhuTrach || '', body.canBoPhuTrach || '',
    body.tinhTrang || 'Đang xử lý', body.ngayKiemTra || '', body.loaiHoSo || '', body.ghiChu || '',
    body.soGiayPhep || '', body.ngayCapPhep || '', body.coQuanCapPhep || '', body.loaiBanVe || '',
    body.soTang || '', body.dienTichXayDung || '', body.dienTichSan || '', fileBanVe, fileGiayPhep
  ];
  db.run(sql, values, function (err) {
    if (err) return res.status(500).json({ success: false, message: err.message });
    db.get(`SELECT * FROM construction_cases WHERE id = ?`, [this.lastID], (e, row) => {
      if (e) return res.status(500).json({ success: false, message: e.message });
      res.json({ success: true, data: row });
    });
  });
});

app.put('/api/cases/:id', upload.fields([{ name: 'fileGiayPhep', maxCount: 1 }, { name: 'fileBanVe', maxCount: 1 }]), (req, res) => {
  db.get(`SELECT * FROM construction_cases WHERE id = ?`, [req.params.id], (err, oldRow) => {
    if (err) return res.status(500).json({ success: false, message: err.message });
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

    const sql = `UPDATE construction_cases SET
      maHoSo=?, chuDauTu=?, diaChi=?, apPhuTrach=?, canBoPhuTrach=?, tinhTrang=?,
      ngayKiemTra=?, loaiHoSo=?, ghiChu=?, soGiayPhep=?, ngayCapPhep=?, coQuanCapPhep=?,
      loaiBanVe=?, soTang=?, dienTichXayDung=?, dienTichSan=?, fileBanVe=?, fileGiayPhep=?
      WHERE id=?`;
    const values = [
      req.body.maHoSo || '', req.body.chuDauTu || '', req.body.diaChi || '', req.body.apPhuTrach || '', req.body.canBoPhuTrach || '',
      req.body.tinhTrang || 'Đang xử lý', req.body.ngayKiemTra || '', req.body.loaiHoSo || '', req.body.ghiChu || '',
      req.body.soGiayPhep || '', req.body.ngayCapPhep || '', req.body.coQuanCapPhep || '', req.body.loaiBanVe || '',
      req.body.soTang || '', req.body.dienTichXayDung || '', req.body.dienTichSan || '', newFileBanVe, newFileGiayPhep, req.params.id
    ];
    db.run(sql, values, function (e2) {
      if (e2) return res.status(500).json({ success: false, message: e2.message });
      db.get(`SELECT * FROM construction_cases WHERE id = ?`, [req.params.id], (e3, row) => {
        if (e3) return res.status(500).json({ success: false, message: e3.message });
        res.json({ success: true, data: row });
      });
    });
  });
});

app.delete('/api/cases/:id', (req, res) => {
  db.get(`SELECT * FROM construction_cases WHERE id = ?`, [req.params.id], (err, row) => {
    if (err) return res.status(500).json({ success: false, message: err.message });
    if (!row) return res.status(404).json({ success: false, message: 'Không tìm thấy hồ sơ' });
    deleteFileIfExists(row.fileGiayPhep);
    deleteFileIfExists(row.fileBanVe);
    db.run(`DELETE FROM construction_cases WHERE id = ?`, [req.params.id], function (e2) {
      if (e2) return res.status(500).json({ success: false, message: e2.message });
      res.json({ success: true });
    });
  });
});

app.get('/api/export/excel', (req, res) => {
  db.all(`SELECT * FROM construction_cases ORDER BY id DESC`, [], async (err, rows) => {
    if (err) return res.status(500).send('Lỗi lấy dữ liệu');
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
  });
});

if (fs.existsSync(path.join(PUBLIC_DIR, 'index.html'))) {
  app.use(express.static(PUBLIC_DIR));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api/') || req.path.startsWith('/uploads/')) return next();
    res.sendFile(path.join(PUBLIC_DIR, 'index.html'));
  });
}

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running at port ${PORT}`);
  console.log(`DB: ${DB_PATH}`);
});
