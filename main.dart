import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const QLXayDungApp());
}

class QLXayDungApp extends StatelessWidget {
  const QLXayDungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quản lý xây dựng',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      ),
      home: const HomeScreen(),
    );
  }
}

class ConstructionCase {
  final String maHoSo;
  final String chuDauTu;
  final String diaChi;
  final String apPhuTrach;
  final String canBoPhuTrach;
  final String tinhTrang;
  final String ngayKiemTra;
  final String loaiHoSo;
  final String ghiChu;
  final String soGiayPhep;
  final String ngayCapPhep;
  final String coQuanCapPhep;
  final String loaiBanVe;
  final String soTang;
  final String dienTichXayDung;
  final String dienTichSan;
  final String fileBanVe;
  final String fileGiayPhep;

  const ConstructionCase({
    required this.maHoSo,
    required this.chuDauTu,
    required this.diaChi,
    required this.apPhuTrach,
    required this.canBoPhuTrach,
    required this.tinhTrang,
    required this.ngayKiemTra,
    required this.loaiHoSo,
    required this.ghiChu,
    required this.soGiayPhep,
    required this.ngayCapPhep,
    required this.coQuanCapPhep,
    required this.loaiBanVe,
    required this.soTang,
    required this.dienTichXayDung,
    required this.dienTichSan,
    required this.fileBanVe,
    required this.fileGiayPhep,
  });

  Map<String, dynamic> toMap() {
    return {
      'maHoSo': maHoSo,
      'chuDauTu': chuDauTu,
      'diaChi': diaChi,
      'apPhuTrach': apPhuTrach,
      'canBoPhuTrach': canBoPhuTrach,
      'tinhTrang': tinhTrang,
      'ngayKiemTra': ngayKiemTra,
      'loaiHoSo': loaiHoSo,
      'ghiChu': ghiChu,
      'soGiayPhep': soGiayPhep,
      'ngayCapPhep': ngayCapPhep,
      'coQuanCapPhep': coQuanCapPhep,
      'loaiBanVe': loaiBanVe,
      'soTang': soTang,
      'dienTichXayDung': dienTichXayDung,
      'dienTichSan': dienTichSan,
      'fileBanVe': fileBanVe,
      'fileGiayPhep': fileGiayPhep,
    };
  }

  static String layTenFile(String duLieuFile) {
    if (duLieuFile.trim().isEmpty) return '';
    try {
      if (duLieuFile.trim().startsWith('{')) {
        final map = jsonDecode(duLieuFile) as Map<String, dynamic>;
        return (map['fileName'] ?? '').toString();
      }
    } catch (_) {}
    return '';
  }

  factory ConstructionCase.fromMap(Map<String, dynamic> map) {
    return ConstructionCase(
      maHoSo: map['maHoSo'] ?? '',
      chuDauTu: map['chuDauTu'] ?? '',
      diaChi: map['diaChi'] ?? '',
      apPhuTrach: map['apPhuTrach'] ?? '',
      canBoPhuTrach: map['canBoPhuTrach'] ?? '',
      tinhTrang: map['tinhTrang'] ?? '',
      ngayKiemTra: map['ngayKiemTra'] ?? '',
      loaiHoSo: map['loaiHoSo'] ?? '',
      ghiChu: map['ghiChu'] ?? '',
      soGiayPhep: map['soGiayPhep'] ?? '',
      ngayCapPhep: map['ngayCapPhep'] ?? '',
      coQuanCapPhep: map['coQuanCapPhep'] ?? '',
      loaiBanVe: map['loaiBanVe'] ?? '',
      soTang: map['soTang'] ?? '',
      dienTichXayDung: map['dienTichXayDung'] ?? '',
      dienTichSan: map['dienTichSan'] ?? '',
      fileBanVe: map['fileBanVe'] ?? '',
      fileGiayPhep: map['fileGiayPhep'] ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String storageKey = 'qlxd_cases_v5';

  int currentIndex = 0;
  bool dangTaiDuLieu = true;
  String tuKhoaTimKiem = '';
  String boLocTinhTrang = 'Tất cả';
  String boLocAp = 'Tất cả';
  String boLocCanBo = 'Tất cả';

  List<ConstructionCase> tatCaHoSo = [];

  final List<ConstructionCase> duLieuMau = const [
    ConstructionCase(
      maHoSo: 'HS-001',
      chuDauTu: 'Nguyễn Văn A',
      diaChi: 'Ấp 24, xã Đông Thạnh',
      apPhuTrach: 'Ấp 24',
      canBoPhuTrach: 'Lê Tuấn Khôi',
      tinhTrang: 'Đang xử lý',
      ngayKiemTra: '28/03/2026',
      loaiHoSo: 'Kiểm tra xây dựng',
      ghiChu: 'Kiểm tra hiện trạng công trình.',
      soGiayPhep: '12/GPXD',
      ngayCapPhep: '20/03/2026',
      coQuanCapPhep: 'UBND xã Đông Thạnh',
      loaiBanVe: 'Bản vẽ xin phép',
      soTang: '1 trệt 1 lầu',
      dienTichXayDung: '80 m²',
      dienTichSan: '160 m²',
      fileBanVe: '',
      fileGiayPhep: '',
    ),
    ConstructionCase(
      maHoSo: 'HS-002',
      chuDauTu: 'Trần Thị B',
      diaChi: 'Ấp 33, xã Đông Thạnh',
      apPhuTrach: 'Ấp 33',
      canBoPhuTrach: 'Khang',
      tinhTrang: 'Đã xử lý',
      ngayKiemTra: '27/03/2026',
      loaiHoSo: 'Giấy phép xây dựng',
      ghiChu: 'Hồ sơ đã kiểm tra đầy đủ.',
      soGiayPhep: '25/GPXD',
      ngayCapPhep: '18/03/2026',
      coQuanCapPhep: 'UBND xã Đông Thạnh',
      loaiBanVe: 'Bản vẽ hoàn công',
      soTang: '1 trệt',
      dienTichXayDung: '65 m²',
      dienTichSan: '65 m²',
      fileBanVe: '',
      fileGiayPhep: '',
    ),
    ConstructionCase(
      maHoSo: 'HS-003',
      chuDauTu: 'Lê Văn C',
      diaChi: 'Ấp 110, xã Đông Thạnh',
      apPhuTrach: 'Ấp 110',
      canBoPhuTrach: 'Âu',
      tinhTrang: 'Vi phạm',
      ngayKiemTra: '26/03/2026',
      loaiHoSo: 'Biên bản vi phạm',
      ghiChu: 'Phát hiện xây dựng sai hiện trạng.',
      soGiayPhep: '08/GPXD',
      ngayCapPhep: '10/03/2026',
      coQuanCapPhep: 'UBND xã Đông Thạnh',
      loaiBanVe: 'Bản vẽ xin phép',
      soTang: '1 trệt 2 lầu',
      dienTichXayDung: '90 m²',
      dienTichSan: '270 m²',
      fileBanVe: '',
      fileGiayPhep: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _taiDuLieu();
  }

  Future<void> _taiDuLieu() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);

    if (raw == null || raw.isEmpty) {
      tatCaHoSo = List<ConstructionCase>.from(duLieuMau);
      await _luuDuLieu();
    } else {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      tatCaHoSo = decoded
          .map((e) => ConstructionCase.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    if (!mounted) return;
    setState(() {
      dangTaiDuLieu = false;
    });
  }

  Future<void> _luuDuLieu() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tatCaHoSo.map((e) => e.toMap()).toList());
    await prefs.setString(storageKey, raw);
  }

  String _homNay() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  List<String> get danhSachAp {
    final values = tatCaHoSo.map((e) => e.apPhuTrach).toSet().toList()..sort();
    return ['Tất cả', ...values];
  }

  List<String> get danhSachCanBo {
    final values = tatCaHoSo.map((e) => e.canBoPhuTrach).toSet().toList()..sort();
    return ['Tất cả', ...values];
  }

  List<String> get danhSachTinhTrang => const ['Tất cả', 'Đang xử lý', 'Đã xử lý', 'Vi phạm'];

  List<ConstructionCase> get dsCongTrinhDaLoc {
    final keyword = tuKhoaTimKiem.trim().toLowerCase();

    return tatCaHoSo.where((item) {
      final hopTuKhoa = keyword.isEmpty ||
          item.maHoSo.toLowerCase().contains(keyword) ||
          item.chuDauTu.toLowerCase().contains(keyword) ||
          item.diaChi.toLowerCase().contains(keyword) ||
          item.apPhuTrach.toLowerCase().contains(keyword) ||
          item.canBoPhuTrach.toLowerCase().contains(keyword) ||
          item.tinhTrang.toLowerCase().contains(keyword) ||
          item.loaiHoSo.toLowerCase().contains(keyword) ||
          item.ghiChu.toLowerCase().contains(keyword) ||
          item.soGiayPhep.toLowerCase().contains(keyword) ||
          item.coQuanCapPhep.toLowerCase().contains(keyword) ||
          item.loaiBanVe.toLowerCase().contains(keyword);

      final hopTinhTrang = boLocTinhTrang == 'Tất cả' || item.tinhTrang == boLocTinhTrang;
      final hopAp = boLocAp == 'Tất cả' || item.apPhuTrach == boLocAp;
      final hopCanBo = boLocCanBo == 'Tất cả' || item.canBoPhuTrach == boLocCanBo;

      return hopTuKhoa && hopTinhTrang && hopAp && hopCanBo;
    }).toList();
  }

  int get tongHoSo => tatCaHoSo.length;
  int get dangXuLy => tatCaHoSo.where((e) => e.tinhTrang == 'Đang xử lý').length;
  int get daXuLy => tatCaHoSo.where((e) => e.tinhTrang == 'Đã xử lý').length;
  int get viPham => tatCaHoSo.where((e) => e.tinhTrang == 'Vi phạm').length;

  Future<void> _moTrangThemHoSo() async {
    final ConstructionCase? hoSoMoi = await Navigator.push<ConstructionCase>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCasePage(
          title: 'Thêm hồ sơ công trình',
          ngayMacDinh: _homNay(),
        ),
      ),
    );

    if (hoSoMoi == null) return;
    setState(() {
      tatCaHoSo.insert(0, hoSoMoi);
      currentIndex = 0;
    });
    await _luuDuLieu();
  }

  Future<void> _moTrangSuaHoSo(ConstructionCase item) async {
    final ConstructionCase? ketQua = await Navigator.push<ConstructionCase>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCasePage(
          title: 'Sửa hồ sơ công trình',
          initialData: item,
          ngayMacDinh: item.ngayKiemTra,
        ),
      ),
    );

    if (ketQua == null) return;
    final index = tatCaHoSo.indexOf(item);
    if (index == -1) return;

    setState(() {
      tatCaHoSo[index] = ketQua;
    });
    await _luuDuLieu();
  }

  Future<void> _xoaHoSo(ConstructionCase item) async {
    final bool? xacNhan = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa hồ sơ'),
        content: Text('Anh có chắc muốn xóa hồ sơ ${item.maHoSo} không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (xacNhan != true) return;
    setState(() {
      tatCaHoSo.remove(item);
    });
    await _luuDuLieu();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa hồ sơ ${item.maHoSo}')),
    );
  }

  Future<void> _khoiPhucDuLieuMau() async {
    setState(() {
      tatCaHoSo = List<ConstructionCase>.from(duLieuMau);
      tuKhoaTimKiem = '';
      boLocTinhTrang = 'Tất cả';
      boLocAp = 'Tất cả';
      boLocCanBo = 'Tất cả';
      currentIndex = 0;
    });
    await _luuDuLieu();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã khôi phục dữ liệu mẫu')),
    );
  }

  void _xoaBoLoc() {
    setState(() {
      tuKhoaTimKiem = '';
      boLocTinhTrang = 'Tất cả';
      boLocAp = 'Tất cả';
      boLocCanBo = 'Tất cả';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dangTaiDuLieu) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      DashboardPage(
        dsCongTrinh: dsCongTrinhDaLoc,
        tongHoSo: tongHoSo,
        dangXuLy: dangXuLy,
        daXuLy: daXuLy,
        viPham: viPham,
        danhSachTinhTrang: danhSachTinhTrang,
        danhSachAp: danhSachAp,
        danhSachCanBo: danhSachCanBo,
        boLocTinhTrang: boLocTinhTrang,
        boLocAp: boLocAp,
        boLocCanBo: boLocCanBo,
        onSearchChanged: (value) => setState(() => tuKhoaTimKiem = value),
        onTinhTrangChanged: (value) => setState(() => boLocTinhTrang = value),
        onApChanged: (value) => setState(() => boLocAp = value),
        onCanBoChanged: (value) => setState(() => boLocCanBo = value),
        onClearFilters: _xoaBoLoc,
        onAddCase: _moTrangThemHoSo,
        onEditCase: _moTrangSuaHoSo,
        onDeleteCase: _xoaHoSo,
        onResetSample: _khoiPhucDuLieuMau,
      ),
      const InspectionPage(),
      ReportPage(
        tongHoSo: tongHoSo,
        dangXuLy: dangXuLy,
        daXuLy: daXuLy,
        viPham: viPham,
      ),
      const AccountPage(),
    ];

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => setState(() => currentIndex = index),
              extended: MediaQuery.of(context).size.width >= 1180,
              backgroundColor: Colors.white,
              leading: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.domain, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    if (MediaQuery.of(context).size.width >= 1180)
                      const Text(
                        'QL xây dựng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Tổng quan'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.fact_check_outlined),
                  selectedIcon: Icon(Icons.fact_check),
                  label: Text('Hiện trường'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.insert_chart_outlined),
                  selectedIcon: Icon(Icons.insert_chart),
                  label: Text('Báo cáo'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Tài khoản'),
                ),
              ],
            ),
          Expanded(child: pages[currentIndex]),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) => setState(() => currentIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Tổng quan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fact_check_outlined),
                  selectedIcon: Icon(Icons.fact_check),
                  label: 'Hiện trường',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insert_chart_outlined),
                  selectedIcon: Icon(Icons.insert_chart),
                  label: 'Báo cáo',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Tài khoản',
                ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _moTrangThemHoSo,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm hồ sơ'),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<ConstructionCase> dsCongTrinh;
  final int tongHoSo;
  final int dangXuLy;
  final int daXuLy;
  final int viPham;
  final List<String> danhSachTinhTrang;
  final List<String> danhSachAp;
  final List<String> danhSachCanBo;
  final String boLocTinhTrang;
  final String boLocAp;
  final String boLocCanBo;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onTinhTrangChanged;
  final ValueChanged<String> onApChanged;
  final ValueChanged<String> onCanBoChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onAddCase;
  final ValueChanged<ConstructionCase> onEditCase;
  final ValueChanged<ConstructionCase> onDeleteCase;
  final VoidCallback onResetSample;

  const DashboardPage({
    super.key,
    required this.dsCongTrinh,
    required this.tongHoSo,
    required this.dangXuLy,
    required this.daXuLy,
    required this.viPham,
    required this.danhSachTinhTrang,
    required this.danhSachAp,
    required this.danhSachCanBo,
    required this.boLocTinhTrang,
    required this.boLocAp,
    required this.boLocCanBo,
    required this.onSearchChanged,
    required this.onTinhTrangChanged,
    required this.onApChanged,
    required this.onCanBoChanged,
    required this.onClearFilters,
    required this.onAddCase,
    required this.onEditCase,
    required this.onDeleteCase,
    required this.onResetSample,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              runSpacing: 16,
              spacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Hệ thống quản lý xây dựng',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Bản full lưu trên máy: đính kèm file vào từng hồ sơ',
                      style: TextStyle(color: Color(0xFF667085)),
                    ),
                  ],
                ),
                SizedBox(
                  width: isWide ? 380 : double.infinity,
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: const InputDecoration(
                      hintText: 'Tìm mã hồ sơ, giấy phép, bản vẽ, ấp, cán bộ...',
                      prefixIcon: Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 420,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bảng điều hành',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'File giấy phép và bản vẽ được lưu ngay trong dữ liệu hồ sơ trên máy chủ nội bộ của anh.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      QuickMetric(label: 'Tổng hồ sơ', value: tongHoSo.toString()),
                      QuickMetric(label: 'Đang xử lý', value: dangXuLy.toString()),
                      QuickMetric(label: 'Vi phạm', value: viPham.toString()),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilterPanel(
              danhSachTinhTrang: danhSachTinhTrang,
              danhSachAp: danhSachAp,
              danhSachCanBo: danhSachCanBo,
              boLocTinhTrang: boLocTinhTrang,
              boLocAp: boLocAp,
              boLocCanBo: boLocCanBo,
              onTinhTrangChanged: onTinhTrangChanged,
              onApChanged: onApChanged,
              onCanBoChanged: onCanBoChanged,
              onClearFilters: onClearFilters,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: onAddCase,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm hồ sơ mới'),
                ),
                OutlinedButton.icon(
                  onPressed: onResetSample,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Khôi phục dữ liệu mẫu'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SummaryCard(
                  title: 'Tổng hồ sơ',
                  value: tongHoSo.toString(),
                  icon: Icons.folder_copy_outlined,
                  subText: 'Toàn bộ hồ sơ đang quản lý',
                ),
                SummaryCard(
                  title: 'Đang xử lý',
                  value: dangXuLy.toString(),
                  icon: Icons.pending_actions_outlined,
                  subText: 'Cần tiếp tục theo dõi',
                ),
                SummaryCard(
                  title: 'Đã xử lý',
                  value: daXuLy.toString(),
                  icon: Icons.task_alt,
                  subText: 'Đã hoàn tất hồ sơ',
                ),
                SummaryCard(
                  title: 'Vi phạm',
                  value: viPham.toString(),
                  icon: Icons.gpp_bad_outlined,
                  subText: 'Các trường hợp vi phạm',
                ),
              ],
            ),
            const SizedBox(height: 20),
            isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: RecentCasesCard(
                          dsCongTrinh: dsCongTrinh,
                          onEditCase: onEditCase,
                          onDeleteCase: onDeleteCase,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(child: UpgradePlanCard()),
                    ],
                  )
                : Column(
                    children: [
                      RecentCasesCard(
                        dsCongTrinh: dsCongTrinh,
                        onEditCase: onEditCase,
                        onDeleteCase: onDeleteCase,
                      ),
                      const SizedBox(height: 16),
                      const UpgradePlanCard(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class FilterPanel extends StatelessWidget {
  final List<String> danhSachTinhTrang;
  final List<String> danhSachAp;
  final List<String> danhSachCanBo;
  final String boLocTinhTrang;
  final String boLocAp;
  final String boLocCanBo;
  final ValueChanged<String> onTinhTrangChanged;
  final ValueChanged<String> onApChanged;
  final ValueChanged<String> onCanBoChanged;
  final VoidCallback onClearFilters;

  const FilterPanel({
    super.key,
    required this.danhSachTinhTrang,
    required this.danhSachAp,
    required this.danhSachCanBo,
    required this.boLocTinhTrang,
    required this.boLocAp,
    required this.boLocCanBo,
    required this.onTinhTrangChanged,
    required this.onApChanged,
    required this.onCanBoChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bộ lọc nhanh',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: boLocTinhTrang,
                  decoration: _filterDecoration('Tình trạng'),
                  items: danhSachTinhTrang
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => onTinhTrangChanged(value ?? 'Tất cả'),
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: boLocAp,
                  decoration: _filterDecoration('Ấp'),
                  items: danhSachAp
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => onApChanged(value ?? 'Tất cả'),
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  initialValue: boLocCanBo,
                  decoration: _filterDecoration('Cán bộ phụ trách'),
                  items: danhSachCanBo
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => onCanBoChanged(value ?? 'Tất cả'),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Xóa bộ lọc'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _filterDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class QuickMetric extends StatelessWidget {
  final String label;
  final String value;

  const QuickMetric({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String subText;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF1565C0)),
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(subText, style: const TextStyle(color: Color(0xFF667085))),
        ],
      ),
    );
  }
}

class RecentCasesCard extends StatelessWidget {
  final List<ConstructionCase> dsCongTrinh;
  final ValueChanged<ConstructionCase> onEditCase;
  final ValueChanged<ConstructionCase> onDeleteCase;

  const RecentCasesCard({
    super.key,
    required this.dsCongTrinh,
    required this.onEditCase,
    required this.onDeleteCase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dsCongTrinh.isEmpty ? 'Không có hồ sơ phù hợp' : 'Danh sách hồ sơ',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (dsCongTrinh.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Không tìm thấy hồ sơ theo điều kiện lọc hiện tại.'),
            )
          else
            ...dsCongTrinh.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ConstructionCard(
                  item: item,
                  onEdit: () => onEditCase(item),
                  onDelete: () => onDeleteCase(item),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class UpgradePlanCard extends StatelessWidget {
  const UpgradePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Xong 1', 'Giao diện web đẹp, tổng quan dashboard'),
      ('Xong 2', 'Thêm, sửa, xóa hồ sơ'),
      ('Xong 3', 'Lưu dữ liệu cục bộ bằng shared_preferences'),
      ('Xong 4', 'Lọc theo tình trạng, ấp và cán bộ phụ trách'),
      ('Xong 5', 'Đính kèm file giấy phép và bản vẽ ngay trong dữ liệu hồ sơ'),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bảng nâng cấp',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.$1,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(e.$2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConstructionCard extends StatelessWidget {
  final ConstructionCase item;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ConstructionCard({
    super.key,
    required this.item,
    this.onDelete,
    this.onEdit,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'Đã xử lý':
        return const Color(0xFF12B76A);
      case 'Vi phạm':
        return const Color(0xFFF04438);
      default:
        return const Color(0xFFF79009);
    }
  }

  void _moFile(String duLieuFile) {
    if (duLieuFile.trim().isEmpty) return;

    try {
      if (duLieuFile.trim().startsWith('{')) {
        final map = jsonDecode(duLieuFile) as Map<String, dynamic>;
        final base64Data = (map['base64'] ?? '').toString();
        final mimeType = (map['mimeType'] ?? 'application/octet-stream').toString();
        if (base64Data.isEmpty) return;

        final bytes = base64Decode(base64Data);
        final blob = html.Blob([bytes], mimeType);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, '_blank');
        return;
      }

      html.window.open(duLieuFile, '_blank');
    } catch (_) {
      html.window.open(duLieuFile, '_blank');
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(item.tinhTrang);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                item.maHoSo.split('-').last,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.chuDauTu,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(item.loaiHoSo, style: const TextStyle(color: Color(0xFF1565C0))),
                const SizedBox(height: 4),
                Text('Mã hồ sơ: ${item.maHoSo}'),
                Text('Địa chỉ: ${item.diaChi}'),
                Text('Ấp: ${item.apPhuTrach} • Cán bộ: ${item.canBoPhuTrach}'),
                Text('Ngày kiểm tra: ${item.ngayKiemTra}'),
                if (item.soGiayPhep.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Giấy phép: ${item.soGiayPhep} - ${item.ngayCapPhep}'),
                ],
                if (item.coQuanCapPhep.trim().isNotEmpty)
                  Text('Cơ quan cấp: ${item.coQuanCapPhep}'),
                if (item.loaiBanVe.trim().isNotEmpty)
                  Text('Loại bản vẽ: ${item.loaiBanVe}'),
                if (item.soTang.trim().isNotEmpty || item.dienTichXayDung.trim().isNotEmpty)
                  Text('Quy mô: ${item.soTang} • XD: ${item.dienTichXayDung} • Sàn: ${item.dienTichSan}'),
                if (item.fileGiayPhep.trim().isNotEmpty || item.fileBanVe.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (item.fileGiayPhep.trim().isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _moFile(item.fileGiayPhep),
                          icon: const Icon(Icons.description_outlined, size: 18),
                          label: Text(
                            ConstructionCase.layTenFile(item.fileGiayPhep).isEmpty
                                ? 'Xem giấy phép'
                                : ConstructionCase.layTenFile(item.fileGiayPhep),
                          ),
                        ),
                      if (item.fileBanVe.trim().isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _moFile(item.fileBanVe),
                          icon: const Icon(Icons.architecture_outlined, size: 18),
                          label: Text(
                            ConstructionCase.layTenFile(item.fileBanVe).isEmpty
                                ? 'Xem bản vẽ'
                                : ConstructionCase.layTenFile(item.fileBanVe),
                          ),
                        ),
                    ],
                  ),
                ],
                if (item.ghiChu.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Ghi chú: ${item.ghiChu}'),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.tinhTrang,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Sửa',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Xóa',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InspectionPage extends StatelessWidget {
  const InspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text(
            'Kiểm tra hiện trường',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Ghi nhận nhanh dữ liệu tại công trình',
            style: TextStyle(color: Color(0xFF667085)),
          ),
          SizedBox(height: 20),
          FieldActionCard(
            icon: Icons.camera_alt_outlined,
            title: 'Chụp ảnh công trình',
            subtitle: 'Lưu ảnh hiện trạng tại thời điểm kiểm tra',
          ),
          SizedBox(height: 12),
          FieldActionCard(
            icon: Icons.location_on_outlined,
            title: 'Ghi nhận vị trí GPS',
            subtitle: 'Xác định vị trí kiểm tra ngoài thực địa',
          ),
          SizedBox(height: 12),
          FieldActionCard(
            icon: Icons.description_outlined,
            title: 'Lập biên bản nhanh',
            subtitle: 'Nhập nội dung vi phạm hoặc hiện trạng công trình',
          ),
        ],
      ),
    );
  }
}

class FieldActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FieldActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF667085))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}

class ReportPage extends StatelessWidget {
  final int tongHoSo;
  final int dangXuLy;
  final int daXuLy;
  final int viPham;

  const ReportPage({
    super.key,
    required this.tongHoSo,
    required this.dangXuLy,
    required this.daXuLy,
    required this.viPham,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Báo cáo thống kê',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Báo cáo tuần',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ReportLine(title: 'Tổng số hồ sơ tiếp nhận', value: tongHoSo.toString()),
                ReportLine(title: 'Hồ sơ đang xử lý', value: dangXuLy.toString()),
                ReportLine(title: 'Hồ sơ đã xử lý', value: daXuLy.toString()),
                ReportLine(title: 'Trường hợp vi phạm', value: viPham.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ReportLine extends StatelessWidget {
  final String title;
  final String value;

  const ReportLine({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 8),
          CircleAvatar(
            radius: 42,
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.person, size: 42, color: Color(0xFF1565C0)),
          ),
          SizedBox(height: 12),
          Center(
            child: Text(
              'Anh Tân',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Tổ quản lý xây dựng xã Đông Thạnh',
              style: TextStyle(color: Color(0xFF667085)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddEditCasePage extends StatefulWidget {
  final String title;
  final ConstructionCase? initialData;
  final String ngayMacDinh;

  const AddEditCasePage({
    super.key,
    required this.title,
    this.initialData,
    required this.ngayMacDinh,
  });

  @override
  State<AddEditCasePage> createState() => _AddEditCasePageState();
}

class _AddEditCasePageState extends State<AddEditCasePage> {
  late final TextEditingController maHoSoController;
  late final TextEditingController chuDauTuController;
  late final TextEditingController diaChiController;
  late final TextEditingController apController;
  late final TextEditingController canBoController;
  late final TextEditingController ngayController;
  late final TextEditingController loaiHoSoController;
  late final TextEditingController ghiChuController;
  late final TextEditingController soGiayPhepController;
  late final TextEditingController ngayCapPhepController;
  late final TextEditingController coQuanCapPhepController;
  late final TextEditingController loaiBanVeController;
  late final TextEditingController soTangController;
  late final TextEditingController dienTichXayDungController;
  late final TextEditingController dienTichSanController;
  late final TextEditingController fileBanVeController;
  late final TextEditingController fileGiayPhepController;

  Uint8List? bytesGiayPhep;
  Uint8List? bytesBanVe;
  bool dangXuLyFile = false;
  String tinhTrang = 'Đang xử lý';

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    maHoSoController = TextEditingController(text: data?.maHoSo ?? '');
    chuDauTuController = TextEditingController(text: data?.chuDauTu ?? '');
    diaChiController = TextEditingController(text: data?.diaChi ?? '');
    apController = TextEditingController(text: data?.apPhuTrach ?? '');
    canBoController = TextEditingController(text: data?.canBoPhuTrach ?? '');
    ngayController = TextEditingController(text: data?.ngayKiemTra ?? widget.ngayMacDinh);
    loaiHoSoController = TextEditingController(text: data?.loaiHoSo ?? '');
    ghiChuController = TextEditingController(text: data?.ghiChu ?? '');
    soGiayPhepController = TextEditingController(text: data?.soGiayPhep ?? '');
    ngayCapPhepController = TextEditingController(text: data?.ngayCapPhep ?? '');
    coQuanCapPhepController = TextEditingController(text: data?.coQuanCapPhep ?? '');
    loaiBanVeController = TextEditingController(text: data?.loaiBanVe ?? '');
    soTangController = TextEditingController(text: data?.soTang ?? '');
    dienTichXayDungController = TextEditingController(text: data?.dienTichXayDung ?? '');
    dienTichSanController = TextEditingController(text: data?.dienTichSan ?? '');
    fileBanVeController = TextEditingController(text: data?.fileBanVe ?? '');
    fileGiayPhepController = TextEditingController(text: data?.fileGiayPhep ?? '');
    tinhTrang = data?.tinhTrang ?? 'Đang xử lý';
  }

  @override
  void dispose() {
    maHoSoController.dispose();
    chuDauTuController.dispose();
    diaChiController.dispose();
    apController.dispose();
    canBoController.dispose();
    ngayController.dispose();
    loaiHoSoController.dispose();
    ghiChuController.dispose();
    soGiayPhepController.dispose();
    ngayCapPhepController.dispose();
    coQuanCapPhepController.dispose();
    loaiBanVeController.dispose();
    soTangController.dispose();
    dienTichXayDungController.dispose();
    dienTichSanController.dispose();
    fileBanVeController.dispose();
    fileGiayPhepController.dispose();
    super.dispose();
  }

  Widget _buildInput(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _chonFile({required bool laGiayPhep}) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'dwg'],
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() {
      if (laGiayPhep) {
        bytesGiayPhep = file.bytes;
        fileGiayPhepController.text = file.name;
      } else {
        bytesBanVe = file.bytes;
        fileBanVeController.text = file.name;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã chọn file: ${file.name}')),
    );
  }

  String _luuFileNoiBo(String fileName, Uint8List bytes) {
    final extension = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    String mimeType = 'application/octet-stream';

    if (extension == 'pdf') {
      mimeType = 'application/pdf';
    } else if (extension == 'jpg' || extension == 'jpeg') {
      mimeType = 'image/jpeg';
    } else if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'dwg') {
      mimeType = 'application/octet-stream';
    }

    return jsonEncode({
      'fileName': fileName,
      'mimeType': mimeType,
      'base64': base64Encode(bytes),
    });
  }

  Widget _buildFilePicker({
    required TextEditingController controller,
    required String label,
    required bool laGiayPhep,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInput(controller, label, readOnly: true),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              onPressed: dangXuLyFile ? null : () => _chonFile(laGiayPhep: laGiayPhep),
              icon: const Icon(Icons.attach_file),
              label: const Text('Chọn file'),
            ),
            if (controller.text.trim().isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    controller.clear();
                    if (laGiayPhep) {
                      bytesGiayPhep = null;
                    } else {
                      bytesBanVe = null;
                    }
                  });
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Xóa file'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _luuHoSo() async {
    if (maHoSoController.text.trim().isEmpty ||
        chuDauTuController.text.trim().isEmpty ||
        diaChiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anh nhập giúp em ít nhất mã hồ sơ, chủ đầu tư và địa chỉ'),
        ),
      );
      return;
    }

    setState(() {
      dangXuLyFile = true;
    });

    try {
      String duLieuGiayPhep = widget.initialData?.fileGiayPhep ?? '';
      String duLieuBanVe = widget.initialData?.fileBanVe ?? '';

      if (bytesGiayPhep != null && fileGiayPhepController.text.trim().isNotEmpty) {
        duLieuGiayPhep = _luuFileNoiBo(
          fileGiayPhepController.text.trim(),
          bytesGiayPhep!,
        );
      }

      if (bytesBanVe != null && fileBanVeController.text.trim().isNotEmpty) {
        duLieuBanVe = _luuFileNoiBo(
          fileBanVeController.text.trim(),
          bytesBanVe!,
        );
      }

      final hoSo = ConstructionCase(
        maHoSo: maHoSoController.text.trim(),
        chuDauTu: chuDauTuController.text.trim(),
        diaChi: diaChiController.text.trim(),
        apPhuTrach: apController.text.trim().isEmpty ? 'Chưa cập nhật' : apController.text.trim(),
        canBoPhuTrach: canBoController.text.trim().isEmpty ? 'Chưa phân công' : canBoController.text.trim(),
        tinhTrang: tinhTrang,
        ngayKiemTra: ngayController.text.trim().isEmpty ? widget.ngayMacDinh : ngayController.text.trim(),
        loaiHoSo: loaiHoSoController.text.trim().isEmpty ? 'Hồ sơ khác' : loaiHoSoController.text.trim(),
        ghiChu: ghiChuController.text.trim(),
        soGiayPhep: soGiayPhepController.text.trim(),
        ngayCapPhep: ngayCapPhepController.text.trim(),
        coQuanCapPhep: coQuanCapPhepController.text.trim(),
        loaiBanVe: loaiBanVeController.text.trim(),
        soTang: soTangController.text.trim(),
        dienTichXayDung: dienTichXayDungController.text.trim(),
        dienTichSan: dienTichSanController.text.trim(),
        fileBanVe: duLieuBanVe,
        fileGiayPhep: duLieuGiayPhep,
      );

      if (!mounted) return;
      Navigator.pop(context, hoSo);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lưu file lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          dangXuLyFile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildInput(maHoSoController, 'Mã hồ sơ'),
                const SizedBox(height: 14),
                _buildInput(chuDauTuController, 'Chủ đầu tư'),
                const SizedBox(height: 14),
                _buildInput(diaChiController, 'Địa chỉ công trình'),
                const SizedBox(height: 14),
                _buildInput(apController, 'Ấp phụ trách'),
                const SizedBox(height: 14),
                _buildInput(canBoController, 'Cán bộ phụ trách'),
                const SizedBox(height: 14),
                _buildInput(ngayController, 'Ngày kiểm tra'),
                const SizedBox(height: 14),
                _buildInput(loaiHoSoController, 'Loại hồ sơ'),
                const SizedBox(height: 18),
                const Text(
                  'Thông tin giấy phép xây dựng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInput(soGiayPhepController, 'Số giấy phép xây dựng'),
                const SizedBox(height: 14),
                _buildInput(ngayCapPhepController, 'Ngày cấp giấy phép'),
                const SizedBox(height: 14),
                _buildInput(coQuanCapPhepController, 'Cơ quan cấp phép'),
                const SizedBox(height: 14),
                _buildFilePicker(
                  controller: fileGiayPhepController,
                  label: 'Đính kèm giấy phép xây dựng',
                  laGiayPhep: true,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Thông tin bản vẽ kèm theo giấy phép',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInput(loaiBanVeController, 'Loại bản vẽ'),
                const SizedBox(height: 14),
                _buildInput(soTangController, 'Quy mô / số tầng'),
                const SizedBox(height: 14),
                _buildInput(dienTichXayDungController, 'Diện tích xây dựng'),
                const SizedBox(height: 14),
                _buildInput(dienTichSanController, 'Diện tích sàn'),
                const SizedBox(height: 14),
                _buildFilePicker(
                  controller: fileBanVeController,
                  label: 'Đính kèm bản vẽ',
                  laGiayPhep: false,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: tinhTrang,
                  decoration: InputDecoration(
                    labelText: 'Tình trạng',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Đang xử lý', child: Text('Đang xử lý')),
                    DropdownMenuItem(value: 'Đã xử lý', child: Text('Đã xử lý')),
                    DropdownMenuItem(value: 'Vi phạm', child: Text('Vi phạm')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      tinhTrang = value ?? 'Đang xử lý';
                    });
                  },
                ),
                const SizedBox(height: 14),
                _buildInput(ghiChuController, 'Ghi chú hiện trạng', maxLines: 4),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7E6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Bản này lưu file giấy phép và bản vẽ ngay trong dữ liệu hồ sơ dưới dạng nội bộ. Phù hợp để anh chạy trên server riêng.',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: dangXuLyFile ? null : _luuHoSo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(dangXuLyFile ? Icons.cloud_upload : Icons.save_outlined),
                    label: Text(dangXuLyFile ? 'Đang xử lý file...' : 'Lưu hồ sơ'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
