class Mahasiswa {
  final String nim;
  final String nama;
  final String prodi;
  final String email;

  final String namaPanggilan;
  final String noHp;
  final String passwordPortal;
  final String jenisKelamin;
  final DateTime? tanggalLahir;
  final String tempatLahir;
  final String agama;
  final int semester;
  final String kelas;
  final String statusMahasiswa;
  final double ipk;
  final bool penerimaBeasiswa;
  final bool bersediaMagang;
  final List<String> minat;
  final String alamat;
  final String provinsi;
  final String kotaKabupaten;
  final String? fotoPath;
  final String? dokumenPath;
  final int warnaProfil;
  final bool persetujuanData;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.email,
    this.namaPanggilan = '',
    this.noHp = '',
    this.passwordPortal = '',
    this.jenisKelamin = 'Laki-laki',
    this.tanggalLahir,
    this.tempatLahir = '',
    this.agama = 'Islam',
    this.semester = 1,
    this.kelas = 'A',
    this.statusMahasiswa = 'Aktif',
    this.ipk = 0.0,
    this.penerimaBeasiswa = false,
    this.bersediaMagang = false,
    this.minat = const [],
    this.alamat = '',
    this.provinsi = 'Jawa Barat',
    this.kotaKabupaten = 'Bogor',
    this.fotoPath,
    this.dokumenPath,
    this.warnaProfil = 0xFF6750A4,
    this.persetujuanData = false,
  });
}