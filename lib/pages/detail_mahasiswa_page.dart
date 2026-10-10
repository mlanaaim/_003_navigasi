
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/mahasiswa.dart';
import 'form_mahasiswa_page.dart';

class DetailResult {
  final Mahasiswa? mahasiswa;

  const DetailResult.updated(Mahasiswa this.mahasiswa);
  const DetailResult.deleted() : mahasiswa = null;
}

class DetailMahasiswaPage extends StatefulWidget {
  final Mahasiswa mahasiswa;
  final Set<String> nimLain;

  const DetailMahasiswaPage({
    super.key,
    required this.mahasiswa,
    required this.nimLain,
  });

  @override
  State<DetailMahasiswaPage> createState() =>
      _DetailMahasiswaPageState();
}

class _DetailMahasiswaPageState extends State<DetailMahasiswaPage> {
  Future<void> _edit() async {
    final result = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
        builder: (_) => FormMahasiswaPage(
          mahasiswa: widget.mahasiswa,
          nimTerpakai: widget.nimLain,
        ),
      ),
    );

    if (!mounted || result == null) return;
    Navigator.pop(context, DetailResult.updated(result));
  }

  Future<void> _hapus() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus mahasiswa?'),
        content: Text(
          'Data ${widget.mahasiswa.nama} '
          '(${widget.mahasiswa.nim}) akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    Navigator.pop(context, const DetailResult.deleted());
  }

  Widget _bagian(String judul, List<Widget> isi) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Text(
                judul,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...isi,
          ],
        ),
      ),
    );
  }

  Widget _data(String label, String nilai) {
    return ListTile(
      dense: true,
      title: Text(label),
      subtitle: Text(nilai.isEmpty ? '-' : nilai),
    );
  }

  String _tanggal(DateTime? tanggal) {
    if (tanggal == null) return '-';

    final hari = tanggal.day.toString().padLeft(2, '0');
    final bulan = tanggal.month.toString().padLeft(2, '0');

    return '$hari-$bulan-${tanggal.year}';
  }

  String _warna(int warna) {
    return '#${(warna & 0xFFFFFF).toRadixString(16).toUpperCase().padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mahasiswa;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Mahasiswa'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: Color(m.warnaProfil),
                  backgroundImage: m.fotoPath != null &&
                          File(m.fotoPath!).existsSync()
                      ? FileImage(File(m.fotoPath!))
                      : null,
                  child: m.fotoPath == null ||
                          !File(m.fotoPath!).existsSync()
                      ? const Icon(Icons.person, size: 56)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  m.nama.isEmpty ? 'Mahasiswa' : m.nama,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              _bagian('Identitas Mahasiswa', [
                _data('NIM', m.nim),
                _data('Nama Lengkap', m.nama),
                _data('Nama Panggilan', m.namaPanggilan),
                _data('Program Studi', m.prodi),
                _data('Email', m.email),
                _data('No. HP', m.noHp),
                // Password tidak ditampilkan untuk menjaga privasi.
                _data(
                  'Password Portal',
                  m.passwordPortal.isEmpty ? '-' : '••••••••',
                ),
              ]),

              _bagian('Data Pribadi', [
                _data('Jenis Kelamin', m.jenisKelamin),
                _data('Tanggal Lahir', _tanggal(m.tanggalLahir)),
                _data('Tempat Lahir', m.tempatLahir),
                _data('Agama', m.agama),
                _data('Alamat', m.alamat),
                _data('Provinsi', m.provinsi),
                _data('Kota/Kabupaten', m.kotaKabupaten),
              ]),

              _bagian('Informasi Akademik', [
                _data('Semester', m.semester.toString()),
                _data('Kelas', m.kelas),
                _data('Status Mahasiswa', m.statusMahasiswa),
                _data('IPK', m.ipk.toStringAsFixed(2)),
                _data(
                  'Penerima Beasiswa',
                  m.penerimaBeasiswa ? 'Ya' : 'Tidak',
                ),
                _data(
                  'Bersedia Magang',
                  m.bersediaMagang ? 'Ya' : 'Tidak',
                ),
                _data(
                  'Minat',
                  m.minat.isEmpty ? '-' : m.minat.join(', '),
                ),
              ]),

              _bagian('Dokumen dan Preferensi', [
                _data(
                  'Foto Profil',
                  m.fotoPath == null
                      ? 'Belum ada foto'
                      : m.fotoPath!.split(Platform.pathSeparator).last,
                ),
                _data(
                  'Dokumen/KTM',
                  m.dokumenPath == null
                      ? 'Belum ada dokumen'
                      : m.dokumenPath!.split(Platform.pathSeparator).last,
                ),
                _data('Warna Profil', _warna(m.warnaProfil)),
                _data(
                  'Persetujuan Data',
                  m.persetujuanData ? 'Disetujui' : 'Belum disetujui',
                ),
              ]),

              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Data'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _hapus,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Data'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
