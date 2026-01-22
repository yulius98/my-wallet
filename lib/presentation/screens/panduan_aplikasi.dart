import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/theme/app_theme.dart';
import 'package:my_wallet/presentation/screens/home_screen.dart';

class PanduanAplikasiScreen extends StatefulWidget {
  const PanduanAplikasiScreen({super.key});

  @override
  State<PanduanAplikasiScreen> createState() => _PanduanAplikasiScreenState();
}

class _PanduanAplikasiScreenState extends State<PanduanAplikasiScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.javaneseBrownGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(initialIndex: 0),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.javaneseGold.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.javaneseGold.withValues(alpha: .5),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.javaneseGoldLight,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Panduan Aplikasi",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.javaneseGoldLight,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.backgroundPath),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Cara Kerja Aplikasi"),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.login,
                  title: "1. Login",
                  description:
                      "Masuk menggunakan akun Google untuk sinkronisasi data Anda dengan aman.",
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.account_balance_wallet,
                  title: "2. Masukkan Pendapatan",
                  description:
                      "Navigasi ke layar Wallet dan masukkan pendapatan bulanan Anda.",
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.calculate,
                  title: "3. Alokasi Otomatis",
                  description:
                      "Klik tombol 'Alokasi Pendapatan' untuk menghitung distribusi dana secara otomatis berdasarkan persentase yang telah ditentukan.",
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.edit,
                  title: "4. Edit Alokasi (Opsional)",
                  description:
                      "Anda dapat mengubah alokasi sesuai kebutuhan selama data belum disimpan. Klik tombol 'Edit Data' untuk melakukan penyesuaian.",
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.save,
                  title: "5. Simpan Data",
                  description:
                      "Klik tombol 'Simpan Data' setelah alokasi sesuai. Setelah disimpan, data akan terkunci untuk bulan tersebut.",
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.receipt_long,
                  title: "6. Catat Transaksi",
                  description:
                      "Buka layar Transaction, pilih kategori dari alokasi Anda, dan tambahkan item transaksi. Dana akan otomatis berkurang dari kategori terkait.",
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.history,
                  title: "7. Lihat Riwayat",
                  description:
                      "Cek riwayat transaksi per bulan di layar History untuk memantau pengeluaran Anda.",
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("Pembagian Alokasi Pendapatan"),
                const SizedBox(height: 12),
                _buildAllocationOverview(),

                const SizedBox(height: 30),
                _buildSectionTitle("Detail Alokasi & Alasannya"),
                const SizedBox(height: 12),
                _buildAllocationDetail(
                  "Biaya Hidup & Kewajiban (50%)",
                  "Ini adalah kebutuhan dasar yang tidak bisa dihindari dan penting untuk kelangsungan hidup sehari-hari.",
                  [
                    _buildSubAllocation(
                      "Tempat Tinggal & Utilitas (25%)",
                      "Listrik, air, internet, gas - kebutuhan rumah tangga yang esensial.",
                    ),
                    _buildSubAllocation(
                      "Makanan & Transport (15%)",
                      "Biaya makan sehari-hari dan transportasi untuk mobilitas.",
                    ),
                    _buildSubAllocation(
                      "Asuransi Kesehatan (5%)",
                      "Proteksi kesehatan untuk mengantisipasi biaya medis tak terduga.",
                    ),
                    _buildSubAllocation(
                      "Pengeluaran Rutin Lain (5%)",
                      "Biaya lain yang rutin seperti kebersihan, komunikasi, dll.",
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildAllocationDetail(
                  "Tabungan & Investasi (20%)",
                  "Membangun masa depan finansial yang lebih aman dan mencapai kebebasan finansial.",
                  [
                    _buildSubAllocation(
                      "Dana Darurat (5%)",
                      "Target 6-12x pengeluaran bulanan untuk menghadapi situasi darurat tanpa hutang.",
                    ),
                    _buildSubAllocation(
                      "Investasi Jangka Panjang (15%)",
                      "Untuk pensiun dan kebebasan finansial di masa depan. Investasi ini akan berkembang dengan compounding effect.",
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildAllocationDetail(
                  "Angsuran & Kewajiban (20%)",
                  "Mengelola hutang dengan bijak agar tidak memberatkan kondisi finansial.",
                  [
                    _buildSubAllocation(
                      "Angsuran Rumah/Mobil (10%)",
                      "Cicilan aset besar yang menjadi investasi jangka panjang.",
                    ),
                    _buildSubAllocation(
                      "Angsuran Kartu Kredit (5%)",
                      "Lunasi tepat waktu untuk menghindari bunga tinggi.",
                    ),
                    _buildSubAllocation(
                      "Angsuran Lainnya (5%)",
                      "Cicilan elektronik atau kebutuhan lainnya.",
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                _buildAllocationDetail(
                  "Pengembangan & Gaya Hidup (10%)",
                  "Investasi pada diri sendiri dan menjaga keseimbangan hidup agar tidak burnout.",
                  [
                    _buildSubAllocation(
                      "Kesehatan & Fitness (3%)",
                      "Gym, olahraga, suplemen - investasi kesehatan jangka panjang.",
                    ),
                    _buildSubAllocation(
                      "Skill & Pendidikan (4%)",
                      "Kursus, buku, seminar - meningkatkan value dan potensi income.",
                    ),
                    _buildSubAllocation(
                      "Hiburan & Self Reward (3%)",
                      "Rekreasi, hobi, me-time - menjaga kesehatan mental dan motivasi.",
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                _buildSectionTitle("Mengapa Persentase Seperti Ini?"),
                const SizedBox(height: 12),
                _buildReasonCard(
                  title: "Aturan 50/20/20/10 yang Terbukti",
                  description:
                      "Sistem ini mengadaptasi prinsip keuangan yang telah terbukti efektif oleh banyak financial advisor. Pembagian ini memberikan balance antara kebutuhan saat ini dan masa depan.",
                ),
                const SizedBox(height: 12),
                _buildReasonCard(
                  title: "50% untuk Kebutuhan Dasar",
                  description:
                      "Separuh pendapatan untuk kebutuhan esensial memastikan Anda dapat hidup layak tanpa stress. Jika melebihi 50%, mungkin perlu evaluasi lifestyle atau cari tambahan income.",
                ),
                const SizedBox(height: 12),
                _buildReasonCard(
                  title: "20% untuk Masa Depan",
                  description:
                      "Menabung dan investasi minimal 20% adalah kunci mencapai kebebasan finansial. Dengan konsisten, dalam 10-20 tahun Anda bisa memiliki passive income yang cukup.",
                ),
                const SizedBox(height: 12),
                _buildReasonCard(
                  title: "20% untuk Cicilan Maksimal",
                  description:
                      "Membatasi cicilan di 20% mencegah Anda terjebak dalam debt trap. Jika melebihi, beban finansial akan terlalu berat dan menghambat goals lainnya.",
                ),
                const SizedBox(height: 12),
                _buildReasonCard(
                  title: "10% untuk Quality of Life",
                  description:
                      "Self development dan hiburan penting untuk keseimbangan. Tanpa ini, Anda mudah burnout dan kehilangan motivasi untuk bekerja dan menabung.",
                ),

                const SizedBox(height: 30),
                _buildWarningCard(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppTheme.javaneseBrown,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    Color color = AppTheme.javaneseBrown,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.javaneseBrown.withValues(alpha: .1),
            AppTheme.javaneseGold.withValues(alpha: .1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.javaneseGold.withValues(alpha: .3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Sistem Alokasi Berbasis 50/20/20/10",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.javaneseBrown,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildPercentageBar(
            "Biaya Hidup & Kewajiban",
            "50%",
            AppTheme.javaneseBrown,
          ),
          const SizedBox(height: 12),
          _buildPercentageBar("Tabungan & Investasi", "20%", Colors.green),
          const SizedBox(height: 12),
          _buildPercentageBar("Angsuran & Kewajiban", "20%", Colors.orange),
          const SizedBox(height: 12),
          _buildPercentageBar("Pengembangan & Gaya Hidup", "10%", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildPercentageBar(String label, String percentage, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                widthFactor: double.parse(percentage.replaceAll('%', '')) / 100,
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      percentage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationDetail(
    String title,
    String reason,
    List<Widget> subAllocations,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.javaneseBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...subAllocations,
        ],
      ),
    );
  }

  Widget _buildSubAllocation(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.javaneseGold,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard({
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.javaneseGold.withValues(alpha: .3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppTheme.javaneseGold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.javaneseBrown,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Penting untuk Diketahui!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWarningPoint(
                  "Anda Bisa Mengubah Alokasi",
                  "Jika persentase default tidak sesuai dengan kondisi Anda, Anda bebas melakukan penyesuaian selama data alokasi belum disimpan.",
                ),
                const SizedBox(height: 12),
                _buildWarningPoint(
                  "Cara Mengubah Alokasi",
                  "1. Klik tombol 'Alokasi Pendapatan' untuk generate otomatis\n2. Klik tombol 'Edit Data' untuk mengaktifkan mode edit\n3. Ubah nilai sesuai kebutuhan Anda\n4. Pastikan total = 100% dari pendapatan\n5. Klik 'Simpan Data' setelah selesai",
                ),
                const SizedBox(height: 12),
                _buildWarningPoint(
                  "Setelah Disimpan",
                  "Data alokasi akan terkunci untuk bulan tersebut. Jika perlu mengubah, Anda harus menunggu bulan berikutnya atau menghapus data bulan tersebut.",
                ),
                const SizedBox(height: 12),
                _buildWarningPoint(
                  "Fleksibilitas adalah Kunci",
                  "Setiap orang memiliki kondisi finansial yang berbeda. Gunakan persentase ini sebagai panduan, bukan aturan kaku. Yang terpenting adalah konsistensi dalam menabung dan hidup sesuai kemampuan.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningPoint(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 16, color: Colors.orange.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
