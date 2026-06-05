import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';

// ──────────────────────────────────────────────────
// Argument model yang dikirim ke halaman ini
// ──────────────────────────────────────────────────
class ModuleReaderArgs {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String icon;
  final int points;
  final Color color;
  final String? thumbnailUrl;
  final String? contentUrl;
  final bool alreadyCompleted;

  const ModuleReaderArgs({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    required this.points,
    required this.color,
    this.thumbnailUrl,
    this.contentUrl,
    this.alreadyCompleted = false,
  });
}

// ──────────────────────────────────────────────────
// Halaman utama reader — router antara PDF dan teks
// ──────────────────────────────────────────────────
class ModuleReaderPage extends StatefulWidget {
  final ModuleReaderArgs args;
  final Future<void> Function() onCompleted;

  const ModuleReaderPage({
    super.key,
    required this.args,
    required this.onCompleted,
  });

  @override
  State<ModuleReaderPage> createState() => _ModuleReaderPageState();
}

class _ModuleReaderPageState extends State<ModuleReaderPage> {
  bool _hasCompleted = false;
  bool _isMarkingComplete = false;

  @override
  void initState() {
    super.initState();
    _hasCompleted = widget.args.alreadyCompleted;
  }

  Future<void> _markComplete() async {
    if (_hasCompleted || _isMarkingComplete) return;
    setState(() {
      _hasCompleted = true;
      _isMarkingComplete = true;
    });
    await widget.onCompleted();
    if (mounted) setState(() => _isMarkingComplete = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasPdf = widget.args.contentUrl != null &&
        widget.args.contentUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: hasPdf
          ? const Color(0xFF1A1A2E)
          : const Color(0xFFF8FAFC),
      body: hasPdf
          ? _PdfReaderView(
              module: widget.args,
              hasCompleted: _hasCompleted,
              onCompleted: _markComplete,
            )
          : _TextReaderView(
              module: widget.args,
              hasCompleted: _hasCompleted,
              onCompleted: _markComplete,
            ),
    );
  }
}

// ══════════════════════════════════════════════════
//  PDF READER VIEW
//  Render PDF asli — selesai saat halaman terakhir tercapai
// ══════════════════════════════════════════════════
class _PdfReaderView extends StatefulWidget {
  final ModuleReaderArgs module;
  final bool hasCompleted;
  final Future<void> Function() onCompleted;

  const _PdfReaderView({
    required this.module,
    required this.hasCompleted,
    required this.onCompleted,
  });

  @override
  State<_PdfReaderView> createState() => _PdfReaderViewState();
}

class _PdfReaderViewState extends State<_PdfReaderView> {
  PdfControllerPinch? _pdfController;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isLoaded = false;
  bool _hasError = false;
  bool _hasCompleted = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _hasCompleted = widget.hasCompleted;
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    final url = widget.module.contentUrl!;

    // Flutter Web: Browser tidak bisa fetch PDF lintas domain (CORS)
    // Solusi: buka di tab browser baru
    if (kIsWeb) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      // Tandai selesai otomatis karena PDF dibuka di luar app
      if (mounted && !_hasCompleted) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted && !_hasCompleted) {
          setState(() => _hasCompleted = true);
          widget.onCompleted();
        }
      }
      return;
    }

    // Mobile: fetch langsung via http
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final controller = PdfControllerPinch(
          document: PdfDocument.openData(response.bodyBytes),
        );
        if (mounted) {
          setState(() {
            _pdfController = controller;
            _hasError = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Server mengembalikan status ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);

    // Selesai jika halaman terakhir tercapai
    if (_totalPages > 0 && page >= _totalPages) {
      if (!_hasCompleted) {
        setState(() => _hasCompleted = true);
        widget.onCompleted();
      }
    }
  }

  void _onDocumentLoaded(PdfDocument document) {
    setState(() {
      _totalPages = document.pagesCount;
      _isLoaded = true;
    });

    // Jika hanya 1 halaman, langsung selesai
    if (document.pagesCount == 1 && !_hasCompleted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_hasCompleted) {
          setState(() => _hasCompleted = true);
          widget.onCompleted();
        }
      });
    }
  }

  double get _progress => _totalPages == 0
      ? 0.0
      : (_currentPage / _totalPages).clamp(0.0, 1.0);

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;

    return Column(
      children: [
        // ─── Top Bar ──────────────────────────────────────────────────
        _buildTopBar(context, module),

        // ─── Progress info ────────────────────────────────────────────
        if (_isLoaded) _buildProgressBar(module),

        // ─── PDF Viewer ───────────────────────────────────────────────
        Expanded(
          child: _hasError
              ? _buildErrorView(module)
              : _pdfController == null
                  ? _buildLoadingView(module)
                  : PdfViewPinch(
                      controller: _pdfController!,
                      onDocumentLoaded: _onDocumentLoaded,
                      onDocumentError: (error) {
                        setState(() {
                          _hasError = true;
                          _errorMessage = error.toString();
                        });
                      },
                      onPageChanged: _onPageChanged,
                      builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(),
                        documentLoaderBuilder: (_) =>
                            _buildLoadingView(module),
                        pageLoaderBuilder: (_) =>
                            Container(
                          color: const Color(0xFF1A1A2E),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: Colors.white54),
                          ),
                        ),
                        errorBuilder: (_, error) =>
                            _buildErrorView(module),
                      ),
                    ),
        ),

        // ─── Status bar bawah ─────────────────────────────────────────
        if (_hasCompleted && _isLoaded) _buildCompletedBanner(module),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, ModuleReaderArgs module) {
    return Container(
      color: const Color(0xFF16213E),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        left: 4,
        right: 16,
        bottom: 10,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  module.subtitle,
                  style:
                      GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _hasCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Selesai',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: module.color.withAlpha(51),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: module.color.withAlpha(100)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('+${module.points} poin',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ModuleReaderArgs module) {
    return Container(
      color: const Color(0xFF16213E),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  _hasCompleted
                      ? '✅ Dokumen selesai dibaca'
                      : 'Scroll ke halaman terakhir untuk selesai',
                  style: GoogleFonts.poppins(
                      color: _hasCompleted
                          ? Colors.greenAccent
                          : Colors.white54,
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_currentPage / $_totalPages',
                style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _hasCompleted ? 1.0 : _progress,
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(
                  _hasCompleted ? Colors.green : module.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBanner(ModuleReaderArgs module) {
    return Container(
      color: Colors.green.shade700,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              widget.hasCompleted
                  ? 'Kamu sudah menyelesaikan modul ini sebelumnya.'
                  : 'Selesai! Kamu mendapat +${module.points} poin 🎉',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView(ModuleReaderArgs module) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: module.color),
            const SizedBox(height: 16),
            Text(
              'Memuat dokumen PDF...',
              style: GoogleFonts.poppins(
                  color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Text(
              'Pastikan koneksi internetmu stabil',
              style: GoogleFonts.poppins(
                  color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(ModuleReaderArgs module) {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_rounded,
                  size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat PDF',
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ??
                    'Pastikan kamu terhubung ke internet dan file PDF tersedia.',
                style: GoogleFonts.poppins(
                    color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: module.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoaded = false;
                    _errorMessage = null;
                    _pdfController?.dispose();
                    _pdfController = null;
                  });
                  _loadPdf();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Coba Lagi',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════
//  TEXT READER VIEW
//  Jika tidak ada PDF — konten teks dengan scroll validation >= 90%
// ══════════════════════════════════════════════════
class _TextReaderView extends StatefulWidget {
  final ModuleReaderArgs module;
  final bool hasCompleted;
  final Future<void> Function() onCompleted;

  const _TextReaderView({
    required this.module,
    required this.hasCompleted,
    required this.onCompleted,
  });

  @override
  State<_TextReaderView> createState() => _TextReaderViewState();
}

class _TextReaderViewState extends State<_TextReaderView> {
  final ScrollController _scrollController = ScrollController();
  bool _hasCompleted = false;
  double _readProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _hasCompleted = widget.hasCompleted;
    if (!_hasCompleted) {
      _scrollController.addListener(_onScroll);
      // Logika untuk konten pendek: Cek setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          final max = _scrollController.position.maxScrollExtent;
          // Jika tidak bisa di-scroll (konten pendek), berikan poin setelah 3 detik
          if (max <= 0) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && !_hasCompleted) {
                setState(() => _hasCompleted = true);
                widget.onCompleted();
              }
            });
          }
        }
      });
    } else {
      _readProgress = 1.0;
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final cur = _scrollController.position.pixels;
    
    if (max <= 0) {
      if (!_hasCompleted) {
        setState(() => _readProgress = 1.0);
      }
      return;
    }

    final progress = (cur / max).clamp(0.0, 1.0);
    setState(() => _readProgress = progress);

    if (progress >= 0.90 && !_hasCompleted) {
      setState(() => _hasCompleted = true);
      widget.onCompleted();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final module = widget.module;

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ─── SliverAppBar dengan hero ──────────────────────────────────
        SliverAppBar(
          expandedHeight: module.thumbnailUrl != null ? 240 : 160,
          pinned: true,
          stretch: true,
          backgroundColor: module.color,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          actions: [
            if (_hasCompleted)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('Selesai',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
            ],
            background: module.thumbnailUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        module.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) =>
                            _heroFallback(module),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              module.color.withAlpha(200),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _heroFallback(module),
          ),
        ),

        // ─── Progress bar ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progres Membaca',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600),
                    ),
                    Flexible(
                      child: Text(
                        _hasCompleted
                            ? '✅ Selesai'
                            : 'Scroll ke bawah untuk selesai',
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: _hasCompleted
                                ? Colors.green
                                : Colors.grey.shade400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _hasCompleted ? 1.0 : _readProgress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _hasCompleted ? Colors.green : module.color),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        ),

        // ─── Konten teks ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 6),
                Text(
                  module.subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: module.color,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: module.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars_rounded,
                          color: module.color, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '+${module.points} poin setelah membaca',
                        style: GoogleFonts.poppins(
                            color: module.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 20),
                Text(
                  module.content,
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      height: 1.9,
                      color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // ─── Banner status ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: _hasCompleted
                ? Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade400,
                          Colors.green.shade600
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modul Selesai Dibaca!',
                                style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                              Text(
                                widget.hasCompleted
                                    ? 'Kamu sudah menyelesaikan modul ini.'
                                    : '+${module.points} poin telah ditambahkan 🎉',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: module.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: module.color.withAlpha(60)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swipe_down_rounded,
                            color: module.color, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Terus scroll ke bawah untuk mendapatkan +${module.points} poin.',
                            style: GoogleFonts.poppins(
                                color: module.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }

  Widget _heroFallback(ModuleReaderArgs module) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [module.color, module.color.withAlpha(180)],
        ),
      ),
      child: Center(
        child: Text(module.icon, style: const TextStyle(fontSize: 72)),
      ),
    );
  }
}
