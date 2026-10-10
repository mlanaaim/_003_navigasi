import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/mahasiswa.dart';

class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa;
  final Set<String> nimTerpakai;

  const FormMahasiswaPage({
    super.key,
    this.mahasiswa,
    required this.nimTerpakai,
  });

  @override
  State<FormMahasiswaPage> createState() =>
      _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  late final TextEditingController _nim;
  late final TextEditingController _nama;
  late final TextEditingController _prodi;
  late final TextEditingController _email;
  late final TextEditingController _namaPanggilan;
  late final TextEditingController _noHp;
  late final TextEditingController _password;
  late final TextEditingController _tempatLahir;
  late final TextEditingController _alamat;

  String _jenisKelamin = 'Laki-laki';
  DateTime? _tanggalLahir;
  String _agama = 'Islam';
  int _semester = 1;
  String _kelas = 'A';
  String _status = 'Aktif';
  double _ipk = 0;
  bool _beasiswa = false;
  bool _magang = false;
  final Set<String> _minat = {};
  String _provinsi = 'Jawa Barat';
  String _kota = 'Bogor';
  String? _fotoPath;
  String? _dokumenPath;
  String? _dokumenNama;
  int _warna = 0xFF6750A4;
  bool _persetujuan = false;


  final List<String> _daftarAgama = [
    'Islam',
    'Kristen',
    'Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  final List<String> _daftarMinat = [
    'Mobile',
    'Web',
    'AI',
    'UI/UX',
    'Data',
  ];

  final List<String> _daftarProvinsi = [
    'Jawa Barat',
    'DKI Jakarta',
    'Banten',
    'Jawa Tengah',
    'Jawa Timur',
    'DI Yogyakarta',
    'Sumatera Utara',
    'Sumatera Barat',
    'Bali',
    'Lainnya',
  ];

  final List<String> _daftarKota = [
    'Bogor',
    'Depok',
    'Bandung',
    'Bekasi',
    'Tangerang',
    'Jakarta',
    'Semarang',
    'Surabaya',
    'Lainnya',
  ];

  final List<Color> _daftarWarna = [
    const Color(0xFF6750A4),
    const Color(0xFF1565C0),
    const Color(0xFF00897B),
    const Color(0xFFE65100),
    const Color(0xFFC62828),
    const Color(0xFF6D4C41),
    const Color(0xFF37474F),
  ];

  @override
  void initState() {
    super.initState();

    final m = widget.mahasiswa;

    _nim = TextEditingController(text: m?.nim ?? '');
    _nama = TextEditingController(text: m?.nama ?? '');
    _prodi = TextEditingController(text: m?.prodi ?? '');
    _email = TextEditingController(text: m?.email ?? '');
    _namaPanggilan =
        TextEditingController(text: m?.namaPanggilan ?? '');
    _noHp = TextEditingController(text: m?.noHp ?? '');
    _password =
        TextEditingController(text: m?.passwordPortal ?? '');
    _tempatLahir =
        TextEditingController(text: m?.tempatLahir ?? '');
    _alamat = TextEditingController(text: m?.alamat ?? '');

    if (m != null) {
      _jenisKelamin = m.jenisKelamin;
      _tanggalLahir = m.tanggalLahir;
      _agama = m.agama;
      _semester = m.semester;
      _kelas = m.kelas;
      _status = m.statusMahasiswa;
      _ipk = m.ipk.clamp(0.0, 4.0).toDouble();
      _beasiswa = m.penerimaBeasiswa;
      _magang = m.bersediaMagang;
      _minat.addAll(m.minat);
      _provinsi = m.provinsi;
      _kota = m.kotaKabupaten;
      _fotoPath = m.fotoPath;
      _dokumenPath = m.dokumenPath;
      _warna = m.warnaProfil;
      _persetujuan = m.persetujuanData;
    }
  }

  @override
  void dispose() {
    _nim.dispose();
    _nama.dispose();
    _prodi.dispose();
    _email.dispose();
    _namaPanggilan.dispose();
    _noHp.dispose();
    _password.dispose();
    _tempatLahir.dispose();
    _alamat.dispose();
    super.dispose();
  }

  String? _wajib(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong';
    }
    return null;
  }

  String? _validasiEmail(String? value) {
    final error = _wajib(value, 'Email');
    if (error != null) return error;

    final email = value!.trim();
    final pola = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!pola.hasMatch(email)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();

    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ??
          DateTime(sekarang.year - 18, sekarang.month, sekarang.day),
      firstDate: DateTime(1940),
      lastDate: sekarang,
      helpText: 'Pilih tanggal lahir',
    );

    if (hasil != null && mounted) {
      setState(() => _tanggalLahir = hasil);
    }
  }

  Future<void> _pilihFoto() async {
    try {
      final foto = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (foto != null && mounted) {
        setState(() => _fotoPath = foto.path);
      }
    } on PlatformException catch (e) {
      if (mounted) {
        _pesan('Gagal memilih foto: ${e.message ?? e.code}');
      }
    }
  }

 
Future<void> _pilihDokumen() async {
  final hasil = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
  );

  if (hasil.isEmpty) return;

  final dokumen = hasil.first;

  setState(() {
    _dokumenPath = dokumen.path ?? dokumen.name;
  });
}


  void _pesan(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Widget _judul(String teks) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        teks,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _jarak() => const SizedBox(height: 16);

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    bool obscureText = false,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: items.contains(value) ? value : items.first,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(labelBuilder(item)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  String _tanggalTeks(DateTime? tanggal) {
    if (tanggal == null) return 'Pilih tanggal lahir';

    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');

    return '$hari/$bulan/${tanggal.year}';
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    if (_tanggalLahir == null) {
      _pesan('Silakan pilih tanggal lahir');
      return;
    }

    if (!_persetujuan) {
      _pesan('Persetujuan penggunaan data wajib dicentang');
      return;
    }

    final nim = _nim.text.trim().toLowerCase();

    if (widget.nimTerpakai.contains(nim)) {
      _pesan('NIM sudah digunakan mahasiswa lain');
      return;
    }

    final prodi = _prodi.text.trim();

    if (prodi.isEmpty) {
      _pesan('Program studi tidak boleh kosong');
      return;
    }

    Navigator.pop(
      context,
      Mahasiswa(
        nim: _nim.text.trim(),
        nama: _nama.text.trim(),
        prodi: prodi,
        email: _email.text.trim(),
        namaPanggilan: _namaPanggilan.text.trim(),
        noHp: _noHp.text.trim(),
        passwordPortal: _password.text,
        jenisKelamin: _jenisKelamin,
        tanggalLahir: _tanggalLahir,
        tempatLahir: _tempatLahir.text.trim(),
        agama: _agama,
        semester: _semester,
        kelas: _kelas,
        statusMahasiswa: _status,
        ipk: _ipk,
        penerimaBeasiswa: _beasiswa,
        bersediaMagang: _magang,
        minat: List.unmodifiable(_minat),
        alamat: _alamat.text.trim(),
        provinsi: _provinsi,
        kotaKabupaten: _kota,
        fotoPath: _fotoPath,
        dokumenPath: _dokumenPath,
        warnaProfil: _warna,
        persetujuanData: _persetujuan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mahasiswa == null
              ? 'Tambah Mahasiswa'
              : 'Edit Mahasiswa',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _judul('Identitas Mahasiswa'),

                _field(
                  controller: _nim,
                  label: 'NIM',
                  validator: (v) {
                    final error = _wajib(v, 'NIM');
                    if (error != null) return error;

                    if (widget.nimTerpakai
                        .contains(v!.trim().toLowerCase())) {
                      return 'NIM sudah digunakan';
                    }
                    return null;
                  },
                ),
                _jarak(),

                _field(
                  controller: _nama,
                  label: 'Nama Lengkap',
                  capitalization: TextCapitalization.words,
                  validator: (v) => _wajib(v, 'Nama lengkap'),
                ),
                _jarak(),

                _field(
                  controller: _namaPanggilan,
                  label: 'Nama Panggilan',
                  capitalization: TextCapitalization.words,
                ),
                _jarak(),

                _field(
                  controller: _prodi,
                  label: 'Program Studi',
                  capitalization: TextCapitalization.words,
                  validator: (v) => _wajib(v, 'Program studi'),
                ),
                _jarak(),

                _field(
                  controller: _email,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  validator: _validasiEmail,
                ),
                _jarak(),

                _field(
                  controller: _noHp,
                  label: 'No. HP',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9+ -]'),
                    ),
                  ],
                  validator: (v) {
                    final error = _wajib(v, 'No. HP');
                    if (error != null) return error;
                    if (v!.replaceAll(RegExp(r'\D'), '').length < 8) {
                      return 'Nomor HP terlalu pendek';
                    }
                    return null;
                  },
                ),
                _jarak(),

                _field(
                  controller: _password,
                  label: 'Password Portal',
                  obscureText: true,
                  validator: (v) => _wajib(v, 'Password portal'),
                ),

                _judul('Informasi Pribadi'),

                const Text('Jenis Kelamin'),
                RadioGroup<String>(
                  groupValue: _jenisKelamin,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _jenisKelamin = value);
                    }
                  },
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        value: 'Laki-laki',
                        title: Text('Laki-laki'),
                      ),
                      RadioListTile<String>(
                        value: 'Perempuan',
                        title: Text('Perempuan'),
                      ),
                    ],
                  ),
                ),

                OutlinedButton.icon(
                  onPressed: _pilihTanggal,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_tanggalTeks(_tanggalLahir)),
                ),
                _jarak(),

                _field(
                  controller: _tempatLahir,
                  label: 'Tempat Lahir',
                  capitalization: TextCapitalization.words,
                  validator: (v) => _wajib(v, 'Tempat lahir'),
                ),
                _jarak(),

                _dropdown<String>(
                  label: 'Agama',
                  value: _agama,
                  items: _daftarAgama,
                  labelBuilder: (v) => v,
                  onChanged: (v) {
                    if (v != null) setState(() => _agama = v);
                  },
                ),

                _judul('Akademik'),

                _dropdown<int>(
                  label: 'Semester',
                  value: _semester,
                  items: List.generate(8, (i) => i + 1),
                  labelBuilder: (v) => 'Semester $v',
                  onChanged: (v) {
                    if (v != null) setState(() => _semester = v);
                  },
                ),
                _jarak(),

                const Text('Kelas'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'A', label: Text('A')),
                    ButtonSegment(value: 'B', label: Text('B')),
                    ButtonSegment(value: 'C', label: Text('C')),
                  ],
                  selected: {_kelas},
                  onSelectionChanged: (value) {
                    setState(() => _kelas = value.first);
                  },
                ),
                _jarak(),

                const Text('Status Mahasiswa'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Aktif', 'Cuti', 'Lulus']
                      .map(
                        (status) => ChoiceChip(
                          label: Text(status),
                          selected: _status == status,
                          onSelected: (_) {
                            setState(() => _status = status);
                          },
                        ),
                      )
                      .toList(),
                ),
                _jarak(),

                Text('IPK: ${_ipk.toStringAsFixed(2)}'),
                Slider(
                  value: _ipk,
                  min: 0,
                  max: 4,
                  divisions: 400,
                  label: _ipk.toStringAsFixed(2),
                  onChanged: (value) {
                    setState(() => _ipk = value);
                  },
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Penerima Beasiswa'),
                  subtitle: Text(_beasiswa ? 'Ya' : 'Tidak'),
                  value: _beasiswa,
                  onChanged: (value) {
                    setState(() => _beasiswa = value);
                  },
                ),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bersedia Magang'),
                  value: _magang,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() => _magang = value ?? false);
                  },
                ),

                _judul('Minat'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _daftarMinat.map((minat) {
                    return FilterChip(
                      label: Text(minat),
                      selected: _minat.contains(minat),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _minat.add(minat);
                          } else {
                            _minat.remove(minat);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                _judul('Alamat'),

                _field(
                  controller: _alamat,
                  label: 'Alamat Lengkap',
                  maxLines: 3,
                  capitalization: TextCapitalization.sentences,
                  validator: (v) => _wajib(v, 'Alamat'),
                ),
                _jarak(),

                _dropdown<String>(
                  label: 'Provinsi',
                  value: _provinsi,
                  items: _daftarProvinsi,
                  labelBuilder: (v) => v,
                  onChanged: (v) {
                    if (v != null) setState(() => _provinsi = v);
                  },
                ),
                _jarak(),

                _dropdown<String>(
                  label: 'Kota/Kabupaten',
                  value: _kota,
                  items: _daftarKota,
                  labelBuilder: (v) => v,
                  onChanged: (v) {
                    if (v != null) setState(() => _kota = v);
                  },
                ),

                _judul('Foto Profil'),

                Center(
                  child: GestureDetector(
                    onTap: _pilihFoto,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Color(_warna),
                      backgroundImage: _fotoPath != null &&
                              File(_fotoPath!).existsSync()
                          ? FileImage(File(_fotoPath!))
                          : null,
                      child: _fotoPath == null
                          ? const Icon(
                              Icons.add_a_photo_outlined,
                              size: 32,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _pilihFoto,
                    child: const Text('Pilih Foto dari Galeri'),
                  ),
                ),

                _judul('Dokumen/KTM'),

                OutlinedButton.icon(
                  onPressed: _pilihDokumen,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _dokumenNama ??
                        (_dokumenPath == null
                            ? 'Pilih Dokumen/KTM'
                            : _dokumenPath!.split(Platform.pathSeparator).last),
                  ),
                ),

                _judul('Warna Profil'),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _daftarWarna.map((warna) {
                    final terpilih = warna.toARGB32() == _warna;
                    return InkWell(
                      onTap: () {
                        setState(() => _warna = warna.toARGB32());
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: warna,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: terpilih
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: terpilih
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                _judul('Persetujuan Data'),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _persetujuan,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'Saya menyetujui penggunaan data untuk keperluan '
                    'administrasi mahasiswa.',
                  ),
                  onChanged: (value) {
                    setState(() => _persetujuan = value ?? false);
                  },
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Simpan Data Mahasiswa'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
