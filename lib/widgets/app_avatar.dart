import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? gender;
  final double radius;

  const AppAvatar({super.key, this.gender, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    final genderLower = (gender ?? '').toString().trim().toLowerCase();
    final isFemale = genderLower.contains('perempuan');
    final isMale = genderLower.contains('laki');
    final hasPhoto = isFemale || isMale;
    final photoPath = isFemale
        ? 'assets/image/perempuan.png'
        : 'assets/image/laki-laki.jpg';
    final double outer = radius * 2;

    return SizedBox(
      width: outer,
      height: outer,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer badge circle
          Container(
            width: outer,
            height: outer,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isFemale
                    ? [const Color(0xFFFFC0CB), const Color(0xFFFFB6C1)]
                    : [const Color(0xFF87CEEB), const Color(0xFF5DADE2)],
              ),
              shape: BoxShape.circle,
            ),
          ),

          if (hasPhoto)
            Container(
              width: outer - 12,
              height: outer - 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  photoPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultFace(),
                ),
              ),
            )
          else
            _buildDefaultFace(),
        ],
      ),
    );
  }

  Widget _buildDefaultFace() {
    final double face = radius * 1.6;
    final double eyeSize = radius * 0.25;
    final bool isFemale = (gender ?? '').toString().trim().toLowerCase() == 'perempuan';

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: face,
          height: face,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFDDB3), Color(0xFFFFC299)],
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12, width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
        ),
        if (isFemale)
          Positioned(
            top: radius * 0.02,
            child: Container(
              width: face * 1.05,
              height: face * 0.65,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF6B5B42), Color(0xFF5D4E37)],
                ),
                borderRadius: BorderRadius.circular(face),
              ),
            ),
          )
        else
          Positioned(
            top: radius * 0.05,
            child: Container(
              width: face * 0.95,
              height: face * 0.55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2F2F2F), Color(0xFF1A1A1A)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(face),
                  topRight: Radius.circular(face),
                  bottomLeft: Radius.circular(face * 0.3),
                  bottomRight: Radius.circular(face * 0.3),
                ),
              ),
            ),
          ),
        Positioned(
          top: radius * 0.35,
          left: radius * 0.25,
          child: Container(
            width: eyeSize,
            height: eyeSize,
            decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
            child: Align(
              alignment: const Alignment(-0.3, -0.3),
              child: Container(
                width: eyeSize * 0.4,
                height: eyeSize * 0.4,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
        Positioned(
          top: radius * 0.35,
          right: radius * 0.25,
          child: Container(
            width: eyeSize,
            height: eyeSize,
            decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
            child: Align(
              alignment: const Alignment(-0.3, -0.3),
              child: Container(
                width: eyeSize * 0.4,
                height: eyeSize * 0.4,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
        Positioned(
          top: radius * 0.5,
          child: Container(width: 2, height: radius * 0.25, color: Colors.black26),
        ),
        Positioned(
          bottom: radius * 0.15,
          child: Container(
            width: radius * 0.6,
            height: radius * 0.25,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black45, width: 2.5)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(radius * 0.6),
                bottomRight: Radius.circular(radius * 0.6),
              ),
            ),
          ),
        ),
        if (isFemale)
          Positioned(
            left: -radius * 0.15,
            top: radius * 0.2,
            child: Container(
              width: radius * 0.6,
              height: radius * 0.9,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xFF6B5B42), Color(0xFF5D4E37)],
                ),
                borderRadius: BorderRadius.circular(radius * 0.45),
              ),
            ),
          ),
      ],
    );
  }
}
